use bf

# Execute a pg_ctl command as the PostgreSQL user, using the correct data directory
def cmd [
    command: string # The pg_ctl command to run
] {
    try {
        ^pg pg_ctl $command -D $"(bf env PG_DATA)"
    } catch {
        bf write error $"There was an error running pg_ctl ($command)."
    }
}

# Use pg_ctl to initialise PostgreSQL server
export def init [] { cmd init }

# Use pg_ctl to restart PostgreSQL server
export def restart [] { cmd restart }

# Use pg_ctl to start PostgreSQL status
export def start [] { cmd start }

# Use pg_ctl to get PostgreSQL server status
export def status [] { cmd status }

# Use pg_ctl to stop the PostgreSQL server
export def stop [] { cmd stop }
