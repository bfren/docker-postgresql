use bf
bf env load -x

# Run a basic SQL command against the postgres database - the application user's database may have a different name
def main [] {
    let args = [
        "-U" (bf env PG_USERNAME)
        "-d" "postgres"
        "-c" "SELECT 0;"
    ]
    if ({ ^psql ...$args } | bf handle -c) != 0 { exit 1 }
}
