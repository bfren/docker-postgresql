use bf

# Run preflight checks before executing process
export def preflight [] {
    # load environment
    bf env load

    # manually set executing script
    bf env x_set --override run postgresql

    # if we get here we are ready to start PostgreSQL
    bf write "Starting PostgreSQL."
}
