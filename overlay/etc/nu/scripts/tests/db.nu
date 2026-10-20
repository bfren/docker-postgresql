use std/assert
use ../bf-postgresql/db.nu
use helpers.nu


#======================================================================================================================
# names
#======================================================================================================================

export def names__splits_on_commas_and_removes_spaces [] {
    assert equal ["one" "two" "three"] ("one, two ,three" | db names)
}

export def names__ignores_empty_names [] {
    assert equal ["one"] ("one,, ," | db names)
    assert equal [] ("" | db names)
}


#======================================================================================================================
# databases
#======================================================================================================================

export def without_system__removes_system_databases_and_empty_names [] {
    assert equal ["app" "other"] (["postgres" "app" "" "template0" "other" "template1"] | db without_system)
}

export def get_all__returns_application_databases [] {
    let stubs = helpers stubs
    let result = helpers with_stubs $stubs { with-env (helpers pg_env) { db get_all } }

    assert equal ["app" "other"] $result
}

export def exists__checks_application_databases [] {
    let stubs = helpers stubs
    helpers with_stubs $stubs {
        with-env (helpers pg_env) {
            assert (db exists app)
            assert not (db exists missing)
            assert not (db exists postgres) "system databases are ignored"
        }
    }
}

export def dump__dumps_one_database_with_clean [] {
    let stubs = helpers stubs
    let file = $"(mktemp --directory)/app.sql"
    helpers with_stubs $stubs { with-env (helpers pg_env) { db dump app $file } }

    assert equal "-- dump pg_dump --clean --if-exists app" (open --raw $file | str trim)
}

export def dump__fails_when_database_does_not_exist [] {
    let stubs = helpers stubs
    let file = $"(mktemp --directory)/missing.sql"

    assert error { helpers with_stubs $stubs { with-env (helpers pg_env) { db dump missing $file } } }
}
