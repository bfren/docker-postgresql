# Returns true if the data directory can be used by this server - the data version is empty before the cluster has
# been created, and the server version is empty if it cannot be read (in which case PostgreSQL itself will check)
export def data_matches_server [
    data: string    # Major version from /data/PG_VERSION
    server: string  # Major version of the installed server
]: nothing -> bool {
    let d = $data | str trim
    let s = $server | str trim
    $d == "" or $s == "" or $d == $s
}
