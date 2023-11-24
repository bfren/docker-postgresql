use bf
use ctl.nu

# A file named $name.sql will be used from the root of the /backup directory
export def main [
    name: string    # The name of the database to import
] {
    # ensure the file exists
    let import_file = $"(bf env PG_BACKUP)/($name).sql"
    if ($import_file | bf fs is_not_file) { bf write error $"Cannot find import file ($import_file)." import }

    # ensure the database exists
    bf write $"Importing database ($name) from sql file." import
    if not (ctl database_exists $name) {
        bf write debug " .. creating database"
        { ^pg createdb $"($name)" $"--owner=(bf env PG_USERNAME)" } | bf handle import
    }

    # execute script file using psql
    bf write debug " .. executing script file" import
    { ^pg psql -f $import_file $name } | bf handle import

    # if we get here there have been no errors
    bf write ok "Done."
}
