FROM bfren/alpine-s6:alpine3.18-4.5.3

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
COPY ./13/overlay /

RUN bf-install

VOLUME [ "/data", "/backup" ]
