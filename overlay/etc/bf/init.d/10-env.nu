use bf
use bf-postgresql
bf env load

# Set environment variables
def main [] {
    let data = "/data"
    bf env set PG_DATA $data
    bf env set PG_DATA_CONF $"($data)/postgresql.conf"
    bf env set PG_DATA_HBA_CONF $"($data)/pg_hba.conf"

    let backup = "/backup"
    let backup_basename = "dump"
    bf env set PG_BACKUP $backup
    bf env set PG_DUMP_BASENAME $backup_basename
    bf env set PG_DUMP_FILE_WITHOUT_EXT $"($backup)/($backup_basename)"

    let version = "PG_VERSION"
    let data_version_file = $"($data)/($version)"
    bf env set PG_DATA_VERSION (bf fs read --quiet $data_version_file)
    bf env set PG_DATA_VERSION_FILE $data_version_file
    bf env set PG_SERVER_VERSION (bf fs read --quiet $"/usr/libexec/postgresql/($version)")

    let credentials = bf-postgresql init credentials
    bf env set PG_USERNAME $credentials.username
    bf env set PG_PASSWORD $credentials.password
    bf env set PG_DATABASE $credentials.database

    # return nothing
    return
}
