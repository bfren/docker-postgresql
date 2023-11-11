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
        bf write notok "Container will now quit."
        bf-s6 cont terminate
        return
    }

    # check for a restore file
    if (bf env PG_RESTORE_FILE | path exists) { restore_data }

    # create data if it doesn't exist
    if (bf env PG_DATA_VERSION_FILE | bf fs is_not_file) { create_data }

    # ready to go!
    bf write ok "Server ready."
}

# Create empty database(s)
def create_data [] {
    bf write "Initialising empty data." create_data

    # get variables
    let user = bf env PG_USERNAME
    let pass = bf env PG_PASSWORD

    # start server
    start_server

    # create role for user
    bf write debug $" .. creating role ($user)"
    { $"($pass)\n($pass)" | ^pg createuser --superuser --pwprompt $user } | bf handle create_data

    # create database(s)
    bf env PG_DATABASE | split row "," | each {|x|
        bf write debug $" .. creating database ($x)"
        { ^pg createdb $"($x)" $"--owner=($user)" } | bf handle create_data
    }

    # stop server
    bf-postgresql ctl stop
}

# Restore data from a dump file
def restore_data [] {
    bf write "Restoring data from dump file." restore_data

    # get variables
    let data = bf env PG_DATA
    let restore_file = bf env PG_RESTORE_FILE

    # delete existing data files
    bf write debug " .. deleting existing files" restore_data
    rm -rf $"($data)/*"

    # start server
    start_server

    # run restore
    bf write debug " .. restoring data" restore_data
    { ^pg psql -f $restore_file } | bf handle restore_data

    # stop server
    bf-postgresql ctl stop

    # delete restore file
    rm $restore_file
}

# Run init, generate configuration and start server
def start_server [] {
    # initialise data directory
    bf write debug " .. running dbinit" start_server
    bf-postgresql ctl init

    # generate configuration
    bf write debug " .. generating configuration" start_server
    bf-postgresql conf generate

    # start server
    bf write debug " .. starting server" start_server
    bf-postgresql ctl start
}
