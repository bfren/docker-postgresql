use bf

# Returns true if database $name exists in the cluster
export def exists [
    name: string    # Database name
] {
    $name in (get_all)
}

# Dump a database
export def dump [
    name: string    # The name of the database to dump
    file: string    # The path to save the dump script to
] {
    # ensure the database exists
    if not (exists $name) { bf write error $"Database ($name) does not exist." export }

    # dump database and save to specified file
    { ^pg pg_dump --clean --if-exists $name } | bf handle -s {|x| $x | save --force $file } ctl/dump
}

# Get a list of databases, ignoring system databases
export def get_all [] {
    # ignore these database
    let ignore = [
        "postgres"
        "template0"
        "template1"
    ]

    # execute SQL and process response
    let sql = "SELECT datname FROM pg_database;"
    { ^pg psql -c $sql | ^tail -n+3 | ^head -n-2 | ^xargs } | bf handle -d "Selecting PostgreSQL databases" ctl/get_all | split row " " | where {|x| $x not-in $ignore } | compact
}
