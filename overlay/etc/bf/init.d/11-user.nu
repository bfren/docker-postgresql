use bf
bf env load

# Ensure specified user exists
def main [] {
    # get variables
    let user = bf env --safe PG_USERNAME
    let pass = bf env --safe PG_PASSWORD
    if $user == "" or $pass == "" { bf write error "You must set BF_PG_APPLICATION, or BF_PG_USERNAME and BF_PG_PASSWORD." }

    # if user exists, return
    if (bf user exists $user) {
        bf write $"User ($user) already exists."
        return
    }

    # create user account and set password
    bf user add --uid 1001 $user
    { $"($pass)\n($pass)" | ^passwd $user } | bf handle
}
