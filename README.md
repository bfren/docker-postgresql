# Docker PostgreSQL

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-postgresql) ![Docker Pulls](https://img.shields.io/docker/pulls/bfren/postgresql?label=pulls) ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/bfren/postgresql/postgresql14?label=size)<br/>
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/bfren/docker-postgresql/dev-12?label=PostgreSQL+12) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/bfren/docker-postgresql/dev-13?label=PostgreSQL+13) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/bfren/docker-postgresql/dev-14?label=PostgreSQL+14)

[Docker Repository](https://hub.docker.com/r/bfren/postgresql) - [bfren ecosystem](https://github.com/bfren/docker)

[PostgreSQL](https://www.postgresql.org/) comes pre-installed (12, 13, or 14) with automatic backups built-in.

## Contents

* [Automatic Backups](#automatic-backups)
* [Ports](#ports)
* [Volumes](#volumes)
* [Environment Variables](#environment-variables)
* [Helper Functions](#helper-functions)
* [Licence / Copyright](#licence)

## Automatic Backups

Backups for every database are stored:

* in the `/backup` volume
* in subfolders by date and time (yyMMddhhmm)
* every eight hours

See [For Backups](#for-backups) for configuration variables.

## Ports

* 3306

## Volumes

| Volume    | Purpose                                                                                           |
| --------- | ------------------------------------------------------------------------------------------------- |
| `/data`   | Data files.                                                                                       |
| `/backup` | Backup files (also used for export / import scripts - see [helper functions](#helper-functions)). |

## Environment Variables

### For Backups

| Variable                           | Values                       | Description                                              | Default |
| ---------------------------------- | ---------------------------- | -------------------------------------------------------- | ------- |
| `POSTGRESQL_BACKUP_COMPRESS_FILES` | 0 or 1                       | Whether or not to compress backup files (using gzip).    | 0       |
| `POSTGRESQL_BACKUP_KEEP_FOR_DAYS`  | 0: keep forever<br>Num: days | How many days to keep backups before auto-deleting them. | 14      |

### For Database

| Variable              | Values | Description                                                                               | Default           |
| --------------------- | ------ | ----------------------------------------------------------------------------------------- | ----------------- |
| `POSTGRESQL_USERNAME` | string | Application username - will be used as database name if `POSTGRESQL_DATABASE` is not set. | *None* - required |
| `POSTGRESQL_PASSWORD` | string | Application password.                                                                     | *None* - required |
| `POSTGRESQL_DATABASE` | string | Database name(s) - multiple databases can be separated by a comma.                        | *None*            |

## Helper Functions

| Function     | Purpose                                                                                                                            | Usage                                               |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| `db-backup`  | Run backup manually.                                                                                                               | `docker exec <<CONTAINER>> db-backup`               |
| `db-exists`  | Echoes '0' or '1' depending on whether or not the specified database exists on the server.                                         | `docker exec <<CONTAINER>> db-exists "foo"`         |
| `db-export`  | Dumps the specified database as a SQL file to the root of the `/backup` volume.                                                    | `docker exec <<CONTAINER>> db-export <<DB_NAME>>`   |
| `db-import`  | Executes all files in the root of the `/backup` volume.                                                                            | `docker exec <<CONTAINER>> db-import`               |
| `db-restore` | Deletes all files in `/data` volume, then shuts container down - on restart, the container will restore from the specified backup. | `docker exec <<CONTAINER>> db-restore 202107180500` |
| `db-stop`    | Stops the database server (will automatically terminate the container).                                                            | `docker exec <<CONTAINER>> db-stop`                 |

## Licence

> [MIT](https://mit.bfren.dev/2021)

## Copyright

> Copyright (c) 2021-2022 [bfren](https://bfren.dev) (unless otherwise stated)
