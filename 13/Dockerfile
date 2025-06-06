FROM ghcr.io/bfren/alpine-s6:alpine3.19-5.6.0

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-postgresql"

ARG BF_IMAGE
ARG BF_PUBLISHING
ARG BF_VERSION

EXPOSE 5432

COPY ./overlay /
COPY ./13/overlay /

ENV \
    # set to "1" to compress backup sql files
    BF_PG_BACKUP_COMPRESS_FILES="0" \
    # the duration for which backups will be kept
    BF_PG_BACKUP_KEEP_FOR="28day"

RUN bf-install

VOLUME [ "/backup", "/data" ]
