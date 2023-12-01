use bf
use ctl.nu

# the name of the restoring environment variable
const restoring = "PG_RESTORING"

# Returns true if we are restoring a database backup
export def is_restoring [] { bf env check $restoring }

# Restore the data from a dump file
export def main [] {
    # if dump file does not exist, return
    let dump_file = check_dump_file
    if not $dump_file.exists {
        bf write "Dump file not found." restore
        return
    }

    # mark as restoring so the container is not brought down when we stop the PostgreSQL service
    bf write "Restoring cluster from dump file." restore
    bf env set $restoring 1

    # stop the PostgreSQL service
    bf write debug " .. stopping PostgreSQL service" restore
    ctl stop

    # delete data files
    let data = bf env PG_DATA
    bf write debug " .. deleting data files" restore
    rm -rf $"($data)/*"

    # restart the PostgreSQL service
    bf write debug " .. reinitialising cluster" restore
    ctl init
    ctl start

    # run restore
    bf write debug " .. restoring data" restore
    { ^pg psql -f $dump_file.path } | bf handle restore

    # stop the PostgreSQL service
    bf write debug " .. stopping PostgreSQL service" restore
    ctl stop

    # unset restoring variable and delete dump file
    bf env unset $restoring
    rm -f $dump_file.path

    # if we get here there have been no errors
    bf write ok "Done." restore
}

# Get details of a dump file - returns a record with the following values, having decompressed the file if required
#  - exists: bool   Whether or not a dump file exists
#  - path: string   Absolute path to the dump file if it exists, or null
def check_dump_file [] {
    # get file paths
    let file = bf env PG_DUMP_FILE_WITHOUT_EXT
    let compressed_file = $"($file).bz2"
    let sql_file = $"($file).sql"

    # if there is a compressed file, decompress it
    if ($compressed_file | path exists) {
        # Flags:
        #   -d  Decompress
        #   -f  Force
        { ^pg bzip2 -d -f $compressed_file } | bf handle restore/check_dump_file
    }

    # if the sql file exists, return it
    if ($sql_file | path exists) {
        return {exists: true, path: $sql_file}
    } else {
        return {exists: false}
    }
}

# Restore cluster from a backup dump file
export def from [
    backup: string    # Restore the dump file this backup directory
] {
    # ensure requested backup directory exists
    let backup_dir = $"(bf env PG_BACKUP)/($backup)"
    if ($backup_dir | bf fs is_not_dir) { bf write error $"Backup directory ($backup_dir) does not exist." restore/from }

    # ensure a dump file exists within requested backup directory
    let dump_file = glob $"/backup/($backup)/(bf env PG_DUMP_BASENAME).*" | str join
    if ($dump_file | bf fs is_not_file) { bf write error $"Cannot find a dump file in ($backup_dir)." restore/from }

    # copy dump file to backup root and run restore function
    bf write $"Copying dump file from backup ($backup)." restore/from
    cp --force $dump_file (bf env PG_BACKUP)
    main
}
