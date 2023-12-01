use bf
use restore.nu

# Run preflight checks before executing process
export def preflight [] {
    # load environment
    bf env load

    # manually set executing script
    bf env x_set --override run postgresql

    # exit if we are restoring
    if (restore is_restoring) {
        let for = 5sec
        bf write $"A backup is being restored so sleep for ($for)."
        sleep $for
        exit 0
    }

    # if we get here we are ready to start PostgreSQL
    bf write "Starting PostgreSQL."
}
