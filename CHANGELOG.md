# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [6.0.2] - 2026-11-10

### Changed

- Base image updated to `bfren/alpine-s6` 7.0.2, which updates Nushell to 0.117.0 (your own Nushell scripts may
  need changes), keeps the container starting when `BF_TZ` cannot be set, and no longer hides `CURRENT_FILE` and
  `FILE_PWD` from services - see the
  [Alpine + S6 changelog](https://github.com/bfren/docker-alpine-s6/blob/main/CHANGELOG.md).
- `BF_PG_DATABASE` accepts spaces as well as commas between database names, as `bfren/mariadb` does.
- The README now says to back up before running `pg-restore`: a restore deletes the current data before loading the
  dump, and `psql` carries on past errors, so a bad dump leaves a partly restored cluster. Restores work as in 6.0.1.

## [6.0.1] - 2026-11-06

### Changed

- Base image updated to `bfren/alpine-s6` 7.0.1, which moves to Alpine 3.22.8 and 3.24.4 (with security fixes) and
  rebuilds BusyBox, figlet and Nushell - see the
  [Alpine + S6 changelog](https://github.com/bfren/docker-alpine-s6/blob/main/CHANGELOG.md).

## [6.0.0] - 2026-11-05

### Changed

- **Breaking:** base image updated to `bfren/alpine-s6` 7.0.0 - see the
  [Alpine + S6 changelog](https://github.com/bfren/docker-alpine-s6/blob/main/CHANGELOG.md).
  `bf env set` must now run as root.
- Images are built and published by the shared `bfren/docker` build workflow (`build.yml`), replacing the separate
  `dev.yml` and `publish.yml` workflows.

### Fixed

- A restore no longer deletes the dump file: it is renamed `dump.sql.restored`, and errors from `psql` (which carries
  on after a failed statement) are saved to `dump.sql.log`, with a warning if any statement failed.
- Backups are written straight to the file instead of being held in memory first, so large databases no longer need
  that much memory to back up.
- `pg-export dump` is refused - `/backup/dump.sql` would replace the whole cluster on the next start.

[6.0.2]: https://github.com/bfren/docker-postgresql/compare/v6.0.1...v6.0.2
[6.0.1]: https://github.com/bfren/docker-postgresql/compare/v6.0.0...v6.0.1
[6.0.0]: https://github.com/bfren/docker-postgresql/compare/v5.0.0...v6.0.0
