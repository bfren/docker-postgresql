use bf
bf env load

# Ensure specified user exists
def main [] {
    # get variables
    let user = bf env PG_USERNAME
    let pass = bf env PG_PASSWORD
    if $user == "" or $pass == "" { bf write error "You must set PG_USERNAME and PG_PASSWORD (or PG_APPLICATION)." }

    # if user exists, return
    if (bf user exists $user) {
        bf write $"User ($user) already exists."
        return
    }

    # create user account and set password
    bf write $"Adding user ($user)."
    bf user add --uid 1001 $user
    { $"($pass)\n($pass)" | ^passwd $user } | bf handle
}
