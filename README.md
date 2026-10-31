# PostgreSQL

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-postgresql) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Fpostgresql) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Fpostgresql) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bfren/docker-postgresql/build.yml?branch=main)

[Docker Hub](https://hub.docker.com/r/bfren/postgresql) - [Quay.io](https://quay.io/repository/bfren/postgresql) - [bfren ecosystem](https://github.com/bfren/docker)

## Introduction

[PostgreSQL](https://www.postgresql.org) server with the jobs around it built in: the user and database are created on first start, every database is backed up every eight hours, and a backup can be restored with one command.

It is built on [Alpine + S6](https://github.com/bfren/docker-alpine-s6), with PostgreSQL from Alpine's packages - each PostgreSQL version uses the newest Alpine release that has it.

## Quickstart

`docker-compose.yml`:

```yaml
services:
  db:
    image: quay.io/bfren/postgresql:postgresql18-6.0
    restart: unless-stopped
    environment:
      - BF_PG_APPLICATION=myapp
      - BF_PG_PASSWORD=${DB_PASSWORD}
    volumes:
      - ./v/data:/data
      - ./v/backup:/backup
```

`.env` (keep it out of version control):

```sh
DB_PASSWORD=change-me
```

Run `docker compose up -d`. On first start a user and database called `myapp` are created, and your app (in the same compose file) connects to `db:5432`. To open `psql`:

```sh
docker compose exec db pg psql            # as postgres
docker compose exec db pg psql myapp      # in the myapp database
```

## Features

* 🐘 PostgreSQL 14 to 18 - choose with the image tag
* 🚀 User and database(s) created on first start, as a UTF-8 cluster
* 💾 Every database backed up every eight hours, optionally compressed, with old backups deleted automatically
* ♻️ Restore a backup with one command - or by leaving it in `/backup` before the container starts
* 📤 Export and import single databases
* 🛑 Refuses to start on data from a different major version, and upgrades are a dump and restore
* 🩺 Health check that the application user can query the server
* 👤 PostgreSQL runs as `postgres` (UID 1000), not root

## Tags

Images are published to Docker Hub (`bfren/postgresql`) and Quay.io (`quay.io/bfren/postgresql`) for `linux/amd64`, `linux/arm/v7` and `linux/arm64`. There is no `latest` tag - choose a PostgreSQL version.

| Tag                     | Example                | Use when                                           |
| ----------------------- | ---------------------- | -------------------------------------------------- |
| `postgresqlN`           | `postgresql18`         | You want the latest image for a PostgreSQL version |
| `postgresqlN-MAJOR`     | `postgresql18-6`       | You want updates, but not breaking changes         |
| `postgresqlN-MINOR`     | `postgresql18-6.0`     | You want fixes only - **recommended**              |
| `postgresqlN-VERSION`   | `postgresql18-6.0.0`   | You want to pin this image exactly                 |
| `postgresqlN.M`         | `postgresql18.6`       | You want an exact PostgreSQL release               |
| `postgresqlN.M-VERSION` | `postgresql18.6-6.0.0` | You want to pin both                               |

| PostgreSQL | Release | Alpine | Supported until |
| ---------- | ------- | ------ | --------------- |
| 18         | 18.6    | 3.24   | November 2030   |
| 17         | 17.11   | 3.24   | November 2029   |
| 16         | 16.15   | 3.24   | November 2028   |
| 15         | 15.19   | 3.22   | November 2027   |
| 14         | 14.17   | 3.20   | November 2026   |

PostgreSQL supports each major version for five years - see the [versioning policy](https://www.postgresql.org/support/versioning/). Older versions still work, but get no more fixes: use them only to get existing data out.

## Configuration

### Ports

| Port   | Purpose    |
| ------ | ---------- |
| `5432` | PostgreSQL |

You only need to publish it to reach the database from outside Docker - containers on the same network connect directly.

### Volumes

| Volume    | Purpose                                                                             |
| --------- | ----------------------------------------------------------------------------------- |
| `/data`   | The database cluster, including `postgresql.conf` and `pg_hba.conf`.                |
| `/backup` | Automatic backups, and the files used by `pg-export`, `pg-import` and `pg-restore`. |

Everything in the volumes is owned by `postgres` (UID / GID 1000), and only readable by its owner. On the host, read the files as UID 1000 or with `sudo`.

### Environment Variables

| Variable                      | Values                                                                  | Description                                                          | Default |
| ----------------------------- | ----------------------------------------------------------------------- | -------------------------------------------------------------------- | ------- |
| `BF_PG_APPLICATION`           | string                                                                  | Default for `BF_PG_USERNAME`, `BF_PG_PASSWORD` and `BF_PG_DATABASE`. |         |
| `BF_PG_USERNAME`              | string                                                                  | Application user - created on first start.                           |         |
| `BF_PG_PASSWORD`              | string                                                                  | Application user's password - set on first start.                    |         |
| `BF_PG_DATABASE`              | names                                                                   | Database(s) created on first start - separate several with commas.   |         |
| `BF_PG_BACKUP_COMPRESS_FILES` | `0`, `1`                                                                | Compress backup files with bzip2.                                    | `0`     |
| `BF_PG_BACKUP_KEEP_FOR`       | [Nu duration](https://www.nushell.sh/book/types_of_data.html#durations) | How long to keep backups, e.g. `14day` or `8wk` (Nu has no months).  | `28day` |

Set `BF_PG_APPLICATION`, or `BF_PG_USERNAME` and `BF_PG_PASSWORD` (plus `BF_PG_DATABASE`). Using `BF_PG_APPLICATION` alone makes the password the same as the user name, so set `BF_PG_PASSWORD` too.

See [Alpine + S6](https://github.com/bfren/docker-alpine-s6#environment-variables) for `BF_DEBUG`, `BF_TZ` and the other base image variables. `BF_TZ` sets the time backups run.

## How It Works

On every start, the data version is checked, any dump waiting in `/backup` is restored, the cluster is created if `/data` is empty, and the backup job is added to cron. Then PostgreSQL starts under S6.

### First start

If `/data` is empty, a new cluster is created (UTF-8 encoding, `C` locale), then:

* `postgresql.conf` and `pg_hba.conf` are written to `/data`
* the application user is created as a **superuser**, with `BF_PG_PASSWORD`
* each database in `BF_PG_DATABASE` is created, owned by the application user

This only happens once. Changing the variables later does **not** change the password, user or databases. Clusters created by older versions of this image may use `SQL_ASCII` encoding - check with `pg psql -c '\l'`.

### Connections

* Inside the container, any user can connect without a password (`trust`) - this is how the helper commands work.
* From other containers and machines, users need a password (`scram-sha-256`), over IPv4 or IPv6.

To change these rules or tune PostgreSQL (e.g. `shared_buffers`), edit `/data/postgresql.conf` or `/data/pg_hba.conf` and restart the container. They are only generated when a cluster is created, so your changes are kept. The server time zone is set to `GB`.

### Backups

At a random minute every eight hours (00:xx, 08:xx and 16:xx in `BF_TZ`), `pg-dump` creates a folder in `/backup` named by date and time (`yyyyMMddHHmm`, e.g. `202610171608`) containing:

* `dump.sql` - the whole cluster (users and every database), from `pg_dumpall`, used by `pg-restore`
* `<database>.sql` - each database on its own, from `pg_dump`

`postgres`, `template0` and `template1` are not backed up individually. With `BF_PG_BACKUP_COMPRESS_FILES=1` the files are compressed with bzip2 (`.sql.bz2`). Backup folders older than `BF_PG_BACKUP_KEEP_FOR` are deleted - files in the root of `/backup` are left alone.

### Restore

`pg-restore <folder>` restores a backup folder's `dump.sql` (or `dump.sql.bz2`), e.g. `pg-restore 202610171608`. It **replaces the whole cluster**: PostgreSQL is stopped, `/data` is emptied, a new cluster is created from the dump, and PostgreSQL starts again.

You can also restore while the container is stopped: put `dump.sql` or `dump.sql.bz2` in the root of `/backup` and start the container. The dump file is deleted once it has been restored.

### Export and import

* `pg-export <database>` saves `/backup/<database>.sql`.
* `pg-import <database>` runs `/backup/<database>.sql` in that database, creating it (owned by the application user) if it doesn't exist. Files from `pg-export` and the per-database backup files drop and recreate the tables they contain.

To move a database between containers, `pg-export` in one, copy the file to the other's `/backup`, then `pg-import`.

### Version check

`/data/PG_VERSION` is compared with the server's major version. If they differ, the container explains why and stops - use the image tag that matches the data, or upgrade it.

To upgrade to a newer major version, move the data across in a dump:

1. Run `pg-dump` on the old version, then stop the container.
2. Move the old `/data` somewhere safe (keep it until the upgrade has worked), leaving `/data` empty.
3. Copy `dump.sql` (or `dump.sql.bz2`) from the new backup folder to the root of `/backup`.
4. Change the image tag to the new version and start the container - the dump is [restored](#restore) into a new cluster. Check `docker logs` for errors.

### Helper commands

Run these with `docker exec <container> <command>`.

| Command      | Arguments | Description                                                               |
| ------------ | --------- | ------------------------------------------------------------------------- |
| `pg`         | command   | Run a command as `postgres`, e.g. `pg psql` (add `-it` to `docker exec`). |
| `pg-dump`    |           | Back up now.                                                              |
| `pg-restore` | folder    | Replace the cluster with a backup folder's dump.                          |
| `pg-export`  | database  | Save a database to `/backup/<database>.sql`.                              |
| `pg-import`  | database  | Run `/backup/<database>.sql`, creating the database if needed.            |

### Health check

The health check (inherited from the base image: every 30 seconds) connects as the application user to the `postgres` database and runs `SELECT 0`.

## Testing

```sh
./test.nu                   # builds PostgreSQL 18 and runs /test
./test.nu 14                # or any version directory
./test.nu --all             # every version, in parallel
./run.sh 18                 # builds and opens a shell
./generate-dockerfiles.sh   # regenerates the Dockerfiles from Dockerfile.esh
```

`/test` runs this image's tests alongside the base images' tests: credentials, creating the cluster, user and databases, version checks, backups (including compression and expiry), restore, export and import - using a stub `pg` command, so no server is needed - and the installed commands and configuration. Run it on an old and a new version, e.g. `./test.nu 14` and `./test.nu 18`.

## Troubleshooting

### The container stops straight after starting

Check `docker logs <container>`:

* `You must set BF_PG_APPLICATION, or BF_PG_USERNAME and BF_PG_PASSWORD` - set them.
* `PostgreSQL server vX does not match data vY` - the data is from another major version. See [Version check](#version-check).

### I changed the password but can't log in

The password is only set on [first start](#first-start). Change it with `docker exec -it <container> pg psql -c "ALTER USER myapp PASSWORD 'new';"`, then update `BF_PG_PASSWORD` to match.

### Another container can't connect

Use the container or service name and port `5432`, the application user and its password.

### The container is unhealthy

The application user couldn't run `SELECT 0`. Check it still exists: `docker exec <container> pg psql -c '\du'`.

## FAQs

### Why is the application user a superuser?

So it can create databases and extensions without extra steps. If other people's apps share the server, create a less privileged user for each one instead.

### How do I add another database later?

`docker exec <container> pg createdb newdb --owner=myapp`, or `pg-import newdb` with a `/backup/newdb.sql` file.

### Can I use the official PostgreSQL image's variables, such as `POSTGRES_PASSWORD`?

No - this image only reads the `BF_PG_*` variables.

## Licence

> [MIT](https://mit.bfren.dev/2021)

## Copyright

> Copyright (c) 2021-2026 [bfren](https://bfren.dev) (unless otherwise stated)
