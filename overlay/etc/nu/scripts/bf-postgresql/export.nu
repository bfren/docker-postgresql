use bf
use db.nu

# Database will be exported as a sql file to the root backup directory
export def main [] {
    # capture database name
    let name = $in

    # create path to export file
    let export_file = $"(bf env PG_BACKUP)/($name).sql"

    # dump database to file
    bf write $"Dumping ($name) to ($export_file)." export
    db dump $name $export_file

    # if we get here there have been no errors
    bf write ok "Done." export
}
