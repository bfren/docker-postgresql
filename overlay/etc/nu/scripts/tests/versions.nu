use std/assert
use bf
use ../bf-postgresql/versions.nu


#======================================================================================================================
# data_matches_server
#======================================================================================================================

export def data_matches_server__when_versions_are_equal [] {
    assert (versions data_matches_server "16" "16")
    assert (versions data_matches_server "16\n" "16") "file contents may end with a new line"
}

export def data_matches_server__before_cluster_is_created [] {
    assert (versions data_matches_server "" "16")
}

export def data_matches_server__fails_when_versions_differ [] {
    assert not (versions data_matches_server "15" "16")
    assert not (versions data_matches_server "17" "16")
}


#======================================================================================================================
# installed server
#======================================================================================================================

export def server_version_file__matches_installed_build [] {
    let build = with-env {BF_ETC: "/etc/bf"} { bf build | get PostgreSQL }
    let file = "/usr/libexec/postgresql/PG_VERSION"

    assert ($file | path exists) $"($file) is used to check the data version"
    assert equal ($build | split row "." | first) (open --raw $file | str trim)
}
