use std/assert
use ../bf-postgresql
use helpers.nu


#======================================================================================================================
# dump
#======================================================================================================================

export def backup_dir__is_named_by_date_and_time [] {
    let env_vars = helpers pg_env
    let dir = with-env $env_vars { bf-postgresql dump create_backup_dir }

    assert equal "dir" ($dir | path type)
    assert equal $env_vars.BF_PG_BACKUP ($dir | path dirname)
    assert (($dir | path basename) =~ '^\d{12}$') "backup directories should be named yyyyMMddHHmm"
}


#======================================================================================================================
# restore
#======================================================================================================================

export def check_dump_file__reports_missing_dump [] {
    assert equal {exists: false} (with-env (helpers pg_env) { bf-postgresql restore check_dump_file })
}

export def check_dump_file__finds_sql_dump [] {
    let env_vars = helpers pg_env
    let sql = $"($env_vars.BF_PG_DUMP_FILE_WITHOUT_EXT).sql"
    "SELECT 1;" | save $sql

    assert equal {exists: true, path: $sql} (with-env $env_vars { bf-postgresql restore check_dump_file })
}

export def check_dump_file__decompresses_compressed_backup [] {
    # pg-dump compresses dump.sql to dump.sql.bz2
    let env_vars = helpers pg_env
    let sql = $"($env_vars.BF_PG_DUMP_FILE_WITHOUT_EXT).sql"
    "SELECT 1;" | save $sql
    ^bzip2 $sql

    let result = with-env $env_vars { bf-postgresql restore check_dump_file }

    assert equal {exists: true, path: $sql} $result
    assert equal "SELECT 1;" (open --raw $sql)
}

export def restore__fails_when_backup_does_not_exist [] {
    assert error { with-env (helpers pg_env) { bf-postgresql restore from "202601010000" } }
}

export def restore__fails_when_backup_has_no_dump [] {
    let env_vars = helpers pg_env
    mkdir $"($env_vars.BF_PG_BACKUP)/202601010000"

    assert error { with-env $env_vars { bf-postgresql restore from "202601010000" } }
}


#======================================================================================================================
# export and import
#======================================================================================================================

export def export__saves_database_to_backup_root [] {
    let stubs = helpers stubs
    let env_vars = helpers pg_env

    helpers with_stubs $stubs { with-env $env_vars { "app" | bf-postgresql export-db } }

    assert ((open --raw $"($env_vars.BF_PG_BACKUP)/app.sql") starts-with "-- dump")
}

export def import__runs_file_through_stdin [] {
    # the file is read by root and passed to psql, as the postgres user may not be able to read it
    let stubs = helpers stubs
    let env_vars = helpers pg_env
    "-- app database" | save $"($env_vars.BF_PG_BACKUP)/app.sql"

    helpers with_stubs $stubs { with-env $env_vars { "app" | bf-postgresql import } }

    assert equal "-- app database" (open --raw $"($stubs)/psql.stdin")
    assert ("psql app" in (helpers calls $stubs))
}

export def import__creates_missing_database_owned_by_user [] {
    let stubs = helpers stubs
    let env_vars = helpers pg_env
    "-- new database" | save $"($env_vars.BF_PG_BACKUP)/new.sql"

    helpers with_stubs $stubs { with-env $env_vars { "new" | bf-postgresql import } }

    assert ("createdb new --owner=app" in (helpers calls $stubs))
}

export def import__does_not_create_existing_database [] {
    let stubs = helpers stubs
    let env_vars = helpers pg_env
    "-- app database" | save $"($env_vars.BF_PG_BACKUP)/app.sql"

    helpers with_stubs $stubs { with-env $env_vars { "app" | bf-postgresql import } }

    assert ((helpers calls $stubs) | where {|x| $x starts-with "createdb" } | is-empty)
}

export def import__fails_when_file_does_not_exist [] {
    let stubs = helpers stubs
    assert error { helpers with_stubs $stubs { with-env (helpers pg_env) { "app" | bf-postgresql import } } }
}

export def is_restoring__only_when_flag_is_set [] {
    # the s6 run and finish scripts use this so stopping PostgreSQL during a restore does not stop the container
    assert not (bf-postgresql restore is_restoring)
    assert (with-env {BF_PG_RESTORING: "1"} { bf-postgresql restore is_restoring })
}
