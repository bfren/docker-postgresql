# Environment used by tests - each call uses a new temporary backup directory, so tests can run in parallel
export def pg_env []: nothing -> record {
    let backup = mktemp --directory
    let data = mktemp --directory
    {
        BF_PG_USERNAME: "app"
        BF_PG_PASSWORD: "app-pass"
        BF_PG_DATABASE: "app"
        BF_PG_DATA: $data
        BF_PG_DATA_CONF: $"($data)/postgresql.conf"
        BF_PG_DATA_HBA_CONF: $"($data)/pg_hba.conf"
        BF_PG_BACKUP: $backup
        BF_PG_DUMP_BASENAME: "dump"
        BF_PG_DUMP_FILE_WITHOUT_EXT: $"($backup)/dump"
        BF_PG_BACKUP_COMPRESS_FILES: "0"
        BF_PG_BACKUP_KEEP_FOR: "28day"
        BF_ETC_TEMPLATES: "/etc/bf/templates"
    }
}

# Create a stub pg executable (the real one runs commands as the postgres user) in a new temporary directory, and
# return its path - it appends each command line to <dir>/pg.calls, and:
#   - lists databases for 'psql -At -c'
#   - exits with $STUB_PG_STATUS (default 3 - not running) for 'pg_ctl status'
#   - outputs a line containing its arguments for pg_dump and pg_dumpall
#   - saves its input to <dir>/createuser.stdin for createuser, and to <dir>/psql.stdin for other psql commands
export def stubs []: nothing -> string {
    let dir = mktemp --directory
    let pg = [
        "#!/bin/sh"
        "dir=$(dirname \"$0\")"
        "echo \"$*\" >> \"$dir/pg.calls\""
        "case \"$*\" in"
        "    'pg_ctl status'*) exit ${STUB_PG_STATUS:-3} ;;"
        "    'psql -At -c'*) printf 'postgres\\napp\\ntemplate0\\ntemplate1\\nother\\n' ;;"
        "    pg_dump*) echo \"-- dump $*\" ;;"
        "    createuser*) cat > \"$dir/createuser.stdin\" ;;"
        "    psql*) cat > \"$dir/psql.stdin\" ;;"
        "esac"
    ]
    $pg | str join "\n" | save $"($dir)/pg"
    ^chmod +x $"($dir)/pg"
    $dir
}

# Run a closure with the stubs in $dir first on PATH
export def with_stubs [dir: string, action: closure]: nothing -> any {
    let path = [$dir] | append ($env.PATH | [$in] | flatten | str join (char esep) | split row (char esep))
    with-env {PATH: $path} { do $action }
}

# Return the command lines the stub pg was called with
export def calls [dir: string]: nothing -> list<string> {
    let file = $"($dir)/pg.calls"
    if ($file | path exists) { open --raw $file | lines } else { [] }
}
