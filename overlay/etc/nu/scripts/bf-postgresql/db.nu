use bf

# System databases - these are not backed up individually
export const system_databases = ["postgres" "template0" "template1"]

# Returns true if database $name exists in the cluster
export def exists [
    name: string    # Database name
]: nothing -> bool {
    $name in (get_all)
}

# Dump a database
export def dump [
    name: string    # The name of the database to dump
    file: string    # The path to save the dump script to
]: nothing -> nothing {
    # ensure the database exists
    if not (exists $name) { bf write error $"Database ($name) does not exist." db/dump }

    # dump database and save to specified file
    { ^pg pg_dump --clean --if-exists $name } | bf handle -s {|x| $x | save --force $file } db/dump
}

# Get a list of databases, ignoring system databases
export def get_all []: nothing -> list<string> {
    # flags:
    #   -A  unaligned output
    #   -t  only output rows (no headers or footers)
    let sql = "SELECT datname FROM pg_database;"
    { ^pg psql -At -c $sql } | bf handle -d "Selecting PostgreSQL databases" db/get_all | lines | without_system
}

# Split a comma-separated list of database names (e.g. BF_PG_DATABASE), removing spaces and empty names
export def names []: string -> list<string> {
    split row "," | str trim | where {|x| $x != "" }
}

# Remove system databases and empty values from a list of database names
export def without_system []: list<string> -> list<string> {
    str trim | where {|x| $x != "" and $x not-in $system_databases }
}
