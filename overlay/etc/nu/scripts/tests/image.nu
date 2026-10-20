use std/assert

const commands = [pg pg-dump pg-export pg-import pg-restore]


#======================================================================================================================
# installation
#======================================================================================================================

export def install__postgres_user_has_uid_1000 [] {
    assert equal "1000" (^id -u postgres | str trim)
    assert equal "1000" (^id -g postgres | str trim)
}

export def install__postgresql_executables_are_installed [] {
    for x in [postgres pg_ctl psql pg_dump pg_dumpall createdb createuser bzip2] {
        assert (which $x | is-not-empty) $"($x) should be installed"
    }
}

export def install__run_directory_exists [] {
    assert equal "dir" ("/run/postgresql" | path type)
}


#======================================================================================================================
# commands
#======================================================================================================================

export def commands__are_executable_and_parse [] {
    for x in $commands {
        let path = $"/usr/bin/bf/($x)"
        assert ($path | path exists) $"($x) should exist"
        assert ((^stat -c "%A" $path | str trim) =~ 'x') $"($x) should be executable"

        # check the script with whichever language its first line names
        let shebang = open --raw $path | lines | first
        if ($shebang =~ '(^#!|[/ ])nu( |$)') {
            let result = ^$nu.current-exe --no-config-file --commands $"nu-check ($path)" | complete
            assert equal "true" ($result.stdout | str trim) $"($x) does not parse: ($result.stderr)"
        } else {
            let result = ^sh -n $path | complete
            assert equal 0 $result.exit_code $"($x) is not valid shell: ($result.stderr)"
        }
    }
}

export def healthcheck__connects_to_postgres_database [] {
    # the application user's database may not have the same name as the user
    assert ((open --raw /usr/bin/bf/bf-healthcheck) =~ '-d postgres') "the health check should use the postgres database"
}


#======================================================================================================================
# configuration
#======================================================================================================================

export def pg_hba__requires_passwords_for_network_connections [] {
    let rules = open --raw /etc/bf/templates/pg_hba.conf.esh | lines | where {|x| $x =~ '^host\s' }

    for address in ["0.0.0.0/0" "::/0"] {
        let rule = $rules | where {|x| ($x | split row --regex '\s+' | get 3) == $address }
        assert equal 1 ($rule | length) $"there should be one rule for ($address)"
        assert ($rule.0 | str ends-with "scram-sha-256") $"connections from ($address) should need a password"
    }
}
