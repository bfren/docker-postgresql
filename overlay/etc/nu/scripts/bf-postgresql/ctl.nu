use bf
use conf.nu

# Options passed to initdb when a new cluster is created - without a locale initdb would use SQL_ASCII encoding
export const initdb_options = "--encoding=UTF8 --locale=C"

# Execute a pg_ctl command as the PostgreSQL user, using the correct data directory
def cmd [
    command: string # The pg_ctl command to run
    ...args         # Additional arguments
] {
    try {
        ^pg pg_ctl $command -D $"(bf env PG_DATA)" ...$args
    } catch {
        bf write error $"There was an error running pg_ctl ($command)." ctl/cmd
    }
}

# Use pg_ctl to initialise PostgreSQL server and then regenerate configuration
export def init [] { cmd init "-o" $initdb_options ; conf generate }

# Returns true if the PostgreSQL server is running (pg_ctl status exits with 3 if it is not)
export def is_running []: nothing -> bool {
    let args = [
        "pg_ctl"
        "status"
        "-D"
        (bf env PG_DATA)
    ]
    ({ ^pg ...$args } | bf handle --code-only ctl/is_running) == 0
}

# Use pg_ctl to restart PostgreSQL server
export def restart [] { cmd restart }

# Use pg_ctl to start PostgreSQL status
export def start [] { cmd start }

# Use pg_ctl to get PostgreSQL server status
export def status [] { cmd status }

# Use pg_ctl to stop the PostgreSQL server
export def stop [] { cmd stop }
