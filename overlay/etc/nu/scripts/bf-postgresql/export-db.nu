use bf
use db.nu

# Database will be exported as a sql file to the root backup directory
export def main [] {
    # capture database name
    let name = $in

    # the dump file in the backup root is restored over the whole cluster on the next start
    if $name == (bf env PG_DUMP_BASENAME) { bf write error $"A database called ($name) cannot be exported." export }

    # create path to export file
    let export_file = $"(bf env PG_BACKUP)/($name).sql"

    # dump database to file
    bf write $"Dumping ($name) to ($export_file)." export
    db dump $name $export_file

    # if we get here there have been no errors
    bf write ok "Done." export
}
