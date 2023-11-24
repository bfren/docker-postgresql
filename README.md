# Docker PostgreSQL

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-postgresql) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Fpostgresql) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Fpostgresql) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bfren/docker-postgresql/dev.yml?branch=main)

[Docker Repository](https://hub.docker.com/r/bfren/postgresql) - [bfren ecosystem](https://github.com/bfren/docker)

[PostgreSQL](https://www.postgresql.org/) comes pre-installed (12, 13, 14 or 15) with automatic backups built-in.

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

* 5432

## Volumes

| Volume    | Purpose                                                                                           |
| --------- | ------------------------------------------------------------------------------------------------- |
| `/data`   | Data files.                                                                                       |
| `/backup` | Backup files (also used for export / import scripts - see [helper functions](#helper-functions)). |

## Environment Variables

### For Backups

| Variable                   | Values                       | Description                                              | Default |
| -------------------------- | ---------------------------- | -------------------------------------------------------- | ------- |
| `PG_BACKUP_COMPRESS_FILES` | 0 or 1                       | Whether or not to compress backup files (using gzip).    | 0       |
| `PG_BACKUP_KEEP_FOR_DAYS`  | 0: keep forever<br>Num: days | How many days to keep backups before auto-deleting them. | 14      |

### For Database

| Variable          | Values | Description                                                                                              | Default   |
| ----------------- | ------ | -------------------------------------------------------------------------------------------------------- | --------- |
| `PG_APPLICATION`  | string | Application name - will be used as `PG_DATABASE`, `PG_PASSWORD` and `PG_USERNAME` if they are not set.   | *None*    |
| `PG_DATABASE`     | string | Database name(s) - multiple databases can be separated by a comma.                                       | *None*    |
| `PG_PASSWORD`     | string | Application password.                                                                                    | *None*    |
| `PG_USERNAME`     | string | Application username.                                                                                    | *None*    |

## Helper Functions

| Function      | Arguments         | Purpose                                                                               | Usage                                                 |
| ------------- | ----------------- | ------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| `pg-dump`     | *None*            | Run backup manually.                                                                  | `docker exec <<CONTAINER>> pg-dump`                   |
| `pg-export`   | 1: Database name  | Dumps the specified database as a SQL file to the root of the `/backup` volume.       | `docker exec <<CONTAINER>> pg-export <<DB_NAME>>`     |
| `pg-import`   | 1: Database name  | Executes all files in the root of the `/backup` volume.                               | `docker exec <<CONTAINER>> pg-import <<DB_NAME>>`     |
| `pg-restore`  | 1: Backup set     | Deletes all files in `/data` volume, then restores from the specified backup dump.    | `docker exec <<CONTAINER>> pg-restore 202107180500`   |

## Licence

> [MIT](https://mit.bfren.dev/2021)

## Copyright

> Copyright (c) 2021-2023 [bfren](https://bfren.dev) (unless otherwise stated)
