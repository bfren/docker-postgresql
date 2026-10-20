use bf
use bf-postgresql
use bf-s6
bf env load

def main [] {
    # check data version against server version
    let data_version = bf env --safe PG_DATA_VERSION
    let server_version = bf env --safe PG_SERVER_VERSION
    if (bf-postgresql versions data_matches_server $data_version $server_version) {
        bf write debug "Versions match."
    } else {
        bf write notok $"PostgreSQL server v($server_version) does not match data v($data_version)."
        bf write notok "You must upgrade the data or use a version of this image that matches the data version."
        bf write notok "This container will now quit."
        bf-s6 cont terminate
        exit 1
    }

    # run restore
    bf-postgresql restore

    # create data if it doesn't exist
    if (bf env PG_DATA_VERSION_FILE | bf fs is_not_file) { bf-postgresql init create }

    # ready to go!
    bf write ok "Server ready."
}
