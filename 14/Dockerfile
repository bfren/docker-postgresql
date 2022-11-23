FROM bfren/alpine-s6:alpine3.17-4.4.0

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-postgresql"

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # set to "1" to compress backup sql files
    POSTGRESQL_BACKUP_COMPRESS_FILES="0" \
    # the number of days after which backups will be deleted
    POSTGRESQL_BACKUP_KEEP_FOR_DAYS="28"

EXPOSE 5432

COPY ./overlay /
COPY ./14/overlay /

RUN bf-install

VOLUME [ "/data", "/backup" ]
