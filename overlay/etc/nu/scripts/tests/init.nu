use std/assert
use ../bf-postgresql/init.nu
use helpers.nu


#======================================================================================================================
# credentials
#======================================================================================================================

export def credentials__use_application_for_all_values [] {
    let result = with-env {BF_PG_APPLICATION: "myapp"} { init credentials }

    assert equal {username: "myapp", password: "myapp", database: "myapp"} $result
}

export def credentials__prefer_values_that_are_set [] {
    let vars = {BF_PG_APPLICATION: "myapp", BF_PG_PASSWORD: "secret", BF_PG_DATABASE: "one,two"}
    let result = with-env $vars { init credentials }

    assert equal {username: "myapp", password: "secret", database: "one,two"} $result
}

export def credentials__are_empty_when_nothing_is_set [] {
    # empty values are reported by 11-user.nu, with a message saying which variables to set
    assert equal {username: "", password: "", database: ""} (init credentials)
}


#======================================================================================================================
# create
#======================================================================================================================

# Run create with a stub pg, and $vars added to the test environment - returns the stub directory and environment
def create_with [vars: record = {}]: nothing -> record {
    let stubs = helpers stubs
    let env_vars = helpers pg_env | merge $vars
    helpers with_stubs $stubs { with-env $env_vars { init create } }
    {stubs: $stubs, env: $env_vars}
}

export def create__initialises_utf8_cluster [] {
    let result = create_with
    let initdb = helpers calls $result.stubs | where {|x| $x starts-with "pg_ctl init" }

    assert equal 1 ($initdb | length)
    assert ($initdb.0 | str contains $"-D ($result.env.BF_PG_DATA)")
    assert ($initdb.0 | str contains "--encoding=UTF8")
}

export def create__writes_configuration_to_data_directory [] {
    let result = create_with

    assert ($result.env.BF_PG_DATA_CONF | path exists) "postgresql.conf should be written"
    assert ($result.env.BF_PG_DATA_HBA_CONF | path exists) "pg_hba.conf should be written"
    assert ((open --raw $result.env.BF_PG_DATA_CONF) =~ "(?m)^listen_addresses = '\\*'")
}

export def create__creates_superuser_with_password [] {
    let result = create_with

    assert ("createuser --superuser --pwprompt app" in (helpers calls $result.stubs))
    assert equal "app-pass\napp-pass" (open --raw $"($result.stubs)/createuser.stdin" | str trim)
}

export def create__creates_each_database_owned_by_user [] {
    let result = create_with {BF_PG_DATABASE: "one, two"}
    let calls = helpers calls $result.stubs

    assert ("createdb one --owner=app" in $calls)
    assert ("createdb two --owner=app" in $calls)
}

export def create__starts_server_then_stops_it_when_done [] {
    let calls = create_with | get stubs | helpers calls $in | where {|x| $x =~ '^(pg_ctl (init|start|stop)|createuser|createdb)' }
    let steps = $calls | each {|x| $x | split row " " | first 2 | str join " " }

    assert equal ["pg_ctl init" "pg_ctl start" "createuser --superuser" "createdb app" "pg_ctl stop"] $steps
}
