use std/assert
use ../bf-postgresql/ctl.nu
use helpers.nu


#======================================================================================================================
# init
#======================================================================================================================

export def initdb_options__use_utf8 [] {
    assert ($ctl.initdb_options | str contains "--encoding=UTF8")
}


#======================================================================================================================
# is_running
#======================================================================================================================

export def is_running__is_false_when_pg_ctl_reports_not_running [] {
    let stubs = helpers stubs
    let result = helpers with_stubs $stubs { with-env (helpers pg_env | merge {STUB_PG_STATUS: "3"}) { ctl is_running } }

    assert equal false $result
}

export def is_running__is_true_when_pg_ctl_reports_running [] {
    let stubs = helpers stubs
    let result = helpers with_stubs $stubs { with-env (helpers pg_env | merge {STUB_PG_STATUS: "0"}) { ctl is_running } }

    assert equal true $result
}
