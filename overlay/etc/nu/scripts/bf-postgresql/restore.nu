use bf
use ctl.nu

# the name of the restoring environment variable
const restoring = "PG_RESTORING"

# Returns true if we are restoring a database backup
export def is_restoring [] { bf env check $restoring }

# Restore the data from a dump file
export def main [] {
    # if restore file does not exist, return
    let restore_file = check_restore_file
    if not $restore_file.exists {
        bf write "Restore file not found." backup/restore
        return
    }

    # mark as restoring so the container is not brought down when we stop the PostgreSQL service
    bf write "Restoring data from backup dump." backup/restore
    bf env set $restoring 1

    # stop the PostgreSQL service
    bf write " .. stopping PostgreSQL service" backup/restore
    ctl stop

    # delete data files
    let data = bf env PG_DATA
    bf write debug " .. deleting data files" backup/restore
    rm -rf $"($data)/*"

    # restart the PostgreSQL service
    ctl init
    ctl start

    # run restore
    bf write debug " .. restoring data" backup/restore
    { ^pg psql -f $restore_file.path } | bf handle backup/restore

    # stop the PostgreSQL service
    ctl stop

    # unset restoring variable and delete restore file
    bf env unset $restoring
    rm -f $restore_file.path
}

# Get details of a restore file - returns a record with the following values, having decompressed the file if required
#  - exists: bool   Whether or not a restore file exists
#  - path: string   Absolute path to the restore file if it exists, or null
def check_restore_file [] {
    # get file paths
    let file = bf env PG_RESTORE_FILE_WITHOUT_EXT
    let compressed_file = $"($file).bz2"
    let sql_file = $"($file).sql"

    # if there is a compressed file, decompress it
    if ($compressed_file | path exists) {
        # Flags:
        #   -d  Decompress
        #   -f  Force
        { ^bzip2 -d -f $compressed_file } | bf handle
    }

    # if the sql file exists, return it
    if ($sql_file | path exists) {
        return {exists: true, path: $sql_file}
    } else {
        return {exists: false}
    }
}

export def from [
    date: string
] {

}
