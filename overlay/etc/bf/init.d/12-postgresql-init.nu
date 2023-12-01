use bf
use bf-postgresql
use bf-s6
bf env load

def main [] {
    # check data version against server version
    let data_version = bf env PG_DATA_VERSION 0
    let server_version = bf env PG_SERVER_VERSION 0
    if $data_version == $server_version {
        bf write debug "Versions match."
    } else if $data_version > 0 {
        bf write notok $"PostgreSQL server v($server_version) does not match data v($data_version)."
        bf write notok "You must upgrade the data or use a version of this image that matches the data version."
        bf write notok "This container will now quit."
        bf-s6 cont terminate
        exit 1
    }

    # run restore
    bf-postgresql restore

    # create data if it doesn't exist
    if (bf env PG_DATA_VERSION_FILE | bf fs is_not_file) { create_empty }

    # ready to go!
    bf write ok "Server ready."
}

# Create empty database(s)
def create_empty [] {
    bf write "Initialising empty data." create_empty

    # get variables
    let user = bf env PG_USERNAME
    let pass = bf env PG_PASSWORD

    # start server
    bf-postgresql ctl init
    bf-postgresql ctl start

    # create role for user
    bf write debug $" .. creating role ($user)"
    { $"($pass)\n($pass)" | ^pg createuser --superuser --pwprompt $user } | bf handle create_empty

    # create database(s)
    bf env PG_DATABASE | split row "," | each {|x|
        bf write debug $" .. creating database ($x)"
        { ^pg createdb $"($x)" $"--owner=($user)" } | bf handle create_empty
    }

    # stop server
    bf-postgresql ctl stop
}
