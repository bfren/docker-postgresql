use bf
use conf.nu
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

    # stop the PostgreSQL service (it is not running when restoring during startup)
    if (ctl is_running) {
        bf write debug " .. stopping PostgreSQL service" restore
        ctl stop
    }

    # move the current data out of the way - psql still exits 0 when statements fail, so a bad dump would otherwise
    # leave a partial cluster with the old data gone
    let kept = keep_data
    if $kept != null { bf write $" .. current data moved to ($kept)." restore }

    # restart the PostgreSQL service
    bf write debug " .. reinitialising cluster" restore
    ctl init
    conf generate
    ctl start

    # run restore - psql carries on after an SQL error and still exits 0, so errors are saved to a log and counted
    bf write debug " .. restoring data" restore
    let log = $"($dump_file.path).log"
    { open --raw $dump_file.path | ^pg psql e> $log } | bf handle restore

    # stop the PostgreSQL service
    bf write debug " .. stopping PostgreSQL service" restore
    ctl stop

    # unset restoring variable and keep the dump file, renamed so it is not restored again
    bf env unset $restoring
    mv --force $dump_file.path $"($dump_file.path).restored"

    # warn about errors, which may mean the data was only partly restored
    let count = errors $log | length
    if $count > 0 {
        bf write notok $"($count) error\(s\) during restore - see ($log)." restore
        return
    }

    # if we get here there have been no errors
    bf write ok "Done." restore
}

# Move the files in the data directory to <backup>/<yyyyMMddHHmmss>-before-restore, so they can be recovered if a
# restore goes wrong (the folder expires like any other backup) - returns its path, or null if the data directory was
# empty
export def keep_data []: nothing -> any {
    let data = bf env PG_DATA
    if (ls $data | is-empty) { return }

    # never move into an existing folder - mv would overwrite or skip files there without an error
    let dir = $"(bf env PG_BACKUP)/(date now | format date '%Y%m%d%H%M%S')-before-restore"
    if ($dir | path exists) { bf write error $"($dir) already exists - wait a second and try again." restore/keep_data }
    mkdir $dir
    $"($data)/*" | into glob | mv $in $dir

    # mv does not fail if some files cannot be moved (e.g. the disk is full), so check nothing was left behind
    if (ls $data | is-not-empty) { bf write error $"Unable to move all files from ($data) to ($dir)." restore/keep_data }
    $dir
}

# Return the errors in a psql log, ignoring the ones every restore of a pg_dumpall dump causes: the dump drops and
# creates the postgres role, which already exists in the new cluster and cannot be dropped by itself
export def errors [
    log: string # Path to the psql stderr log
]: nothing -> list<string> {
    let expected = ['current user cannot be dropped' 'role "postgres" already exists']
    open --raw $log
        | lines
        | where {|x| ($x | str contains "ERROR:") and not ($expected | any {|e| $x | str contains $e }) }
}

# Get details of a dump file - returns a record with the following values, having decompressed the file if required
#  - exists: bool   Whether or not a dump file exists
#  - path: string   Absolute path to the dump file (only set if it exists)
export def check_dump_file []: nothing -> record {
    # get file paths
    let file = bf env PG_DUMP_FILE_WITHOUT_EXT
    let sql_file = $"($file).sql"
    let compressed_file = $"($sql_file).bz2"

    # if there is a compressed file, decompress it
    if ($compressed_file | path exists) {
        # Flags:
        #   -d  Decompress
        #   -f  Force
        { ^bzip2 -d -f $compressed_file } | bf handle restore/check_dump_file
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
    backup: string    # Restore the dump file from this backup directory
] {
    # ensure requested backup directory exists
    let backup_dir = $"(bf env PG_BACKUP)/($backup)"
    if ($backup_dir | bf fs is_not_dir) { bf write error $"Backup directory ($backup_dir) does not exist." restore/from }

    # ensure a dump file exists within requested backup directory
    let dump_file = glob $"($backup_dir)/(bf env PG_DUMP_BASENAME).*" | str join
    if ($dump_file | bf fs is_not_file) { bf write error $"Cannot find a dump file in ($backup_dir)." restore/from }

    # copy dump file to backup root and run restore function
    bf write $"Copying dump file from backup ($backup)." restore/from
    cp --force $dump_file (bf env PG_BACKUP)
    main
}
