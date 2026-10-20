use bf
use ctl.nu
use db.nu

# Return the application user's name and password, and the database(s) to create - BF_PG_APPLICATION is used for any
# that are not set
export def credentials []: nothing -> record {
    let application = bf env --safe PG_APPLICATION
    {
        username: (bf env --safe PG_USERNAME $application)
        password: (bf env --safe PG_PASSWORD $application)
        database: (bf env --safe PG_DATABASE $application)
    }
}

# Create a new cluster, with the application user (as a superuser) and database(s)
export def create []: nothing -> nothing {
    bf write "Initialising empty data." init/create

    # get variables
    let user = bf env PG_USERNAME
    let pass = bf env PG_PASSWORD

    # create cluster (and configuration) and start server
    ctl init
    ctl start

    # create role for user
    bf write debug $" .. creating role ($user)" init/create
    { $"($pass)\n($pass)" | ^pg createuser --superuser --pwprompt $user } | bf handle init/create

    # create database(s)
    bf env PG_DATABASE | db names | each {|x|
        bf write debug $" .. creating database ($x)" init/create
        { ^pg createdb $x $"--owner=($user)" } | bf handle init/create
    } | ignore

    # stop server
    ctl stop
}
