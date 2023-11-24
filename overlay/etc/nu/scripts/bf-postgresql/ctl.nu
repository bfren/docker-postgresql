use bf
use conf.nu

# Execute a pg_ctl command as the PostgreSQL user, using the correct data directory
def cmd [
    command: string # The pg_ctl command to run
] {
    try {
        ^pg pg_ctl $command -D $"(bf env PG_DATA)"
    } catch {
        bf write error $"There was an error running pg_ctl ($command)."
    }
}

# Returns true if database $name exists in the cluster
export def database_exists [
    name: string    # Database name
] {
    $name in (get_databases)
}

# Dump a database
export def dump [
    name: string    # The name of the database to dump
    file: string    # The path to save the dump script to
] {
    # ensure the database exists
    if not (database_exists $name) { bf write error $"Database ($name) does not exist." export }

    # dump database and save to specified file
    { ^pg pg_dump $name } | bf handle -s {|x| $x | save --force $file } ctl/dump
}

# Get a list of databases, ignoring system databases
export def get_databases [] {
    # ignore these database
    let ignore = [
        "postgres"
        "template0"
        "template1"
    ]

    # execute SQL and process response
    let sql = "SELECT datname FROM pg_database;"
    { ^pg psql -c $sql | ^tail -n+3 | ^head -n-2 | ^xargs } | bf handle | split row " " | where {|x| $x not-in $ignore }
}

# Use pg_ctl to initialise PostgreSQL server and then regenerate configuration
export def init [] { cmd init ; conf generate }

# Use pg_ctl to restart PostgreSQL server
export def restart [] { cmd restart }

# Use pg_ctl to start PostgreSQL status
export def start [] { cmd start }

# Use pg_ctl to get PostgreSQL server status
export def status [] { cmd status }

# Use pg_ctl to stop the PostgreSQL server
export def stop [] { cmd stop }
