use std/assert
use ../bf-postgresql
use helpers.nu


#======================================================================================================================
# helpers
#======================================================================================================================

# Run a backup with a stub pg, and $vars added to the test environment - returns the backup folder created
def dump_with [vars: record = {}]: nothing -> string {
    let stubs = helpers stubs
    let env_vars = helpers pg_env | merge $vars
    helpers with_stubs $stubs { with-env $env_vars { bf-postgresql dump } }
    ls $env_vars.BF_PG_BACKUP | where type == dir | get name | first
}


#======================================================================================================================
# dump
#======================================================================================================================

export def dump__saves_cluster_and_each_database [] {
    let dir = dump_with
    let files = ls $dir | get name | path basename | sort

    assert equal ["app.sql" "dump.sql" "other.sql"] $files
    assert equal "-- dump pg_dumpall --clean --if-exists" (open --raw $"($dir)/dump.sql" | str trim)
    assert equal "-- dump pg_dump --clean --if-exists app" (open --raw $"($dir)/app.sql" | str trim)
}

export def dump__compresses_files_when_enabled [] {
    let dir = dump_with {BF_PG_BACKUP_COMPRESS_FILES: "1"}
    let files = ls $dir | get name | path basename | sort

    assert equal ["app.sql.bz2" "dump.sql.bz2" "other.sql.bz2"] $files
    assert equal "-- dump pg_dumpall --clean --if-exists" (^bzip2 -dc $"($dir)/dump.sql.bz2" | str trim)
}

export def dump__removes_expired_backups_only [] {
    let stubs = helpers stubs
    let env_vars = helpers pg_env
    let expired = $"($env_vars.BF_PG_BACKUP)/202001010000"
    let export = $"($env_vars.BF_PG_BACKUP)/app.sql"
    mkdir $expired
    ^touch -t 202001010000 $expired
    "-- exported" | save $export
    ^touch -t 202001010000 $export

    helpers with_stubs $stubs { with-env $env_vars { bf-postgresql dump } }

    assert not ($expired | path exists) "backup folders older than BF_PG_BACKUP_KEEP_FOR should be deleted"
    assert ($export | path exists) "files in the root of /backup should be kept"
    assert equal 1 (ls $env_vars.BF_PG_BACKUP | where type == dir | length) "the new backup should be kept"
}
