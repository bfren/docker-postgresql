use bf
use ctl.nu

# Database $name will be exported as a sql file to the root backup directory
export def main [
    name: string    # The name of the database to export
] {
    ctl dump $name $"(bf env PG_BACKUP)/($name).sql"
}
