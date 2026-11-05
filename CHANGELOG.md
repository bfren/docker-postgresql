# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[6.0.0]: https://github.com/bfren/docker-postgresql/compare/v5.0.0...v6.0.0
