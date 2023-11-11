FROM bfren/alpine-s6:alpine3.18-5.0.0-dev

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-postgresql"

ARG BF_IMAGE
ARG BF_VERSION

EXPOSE 5432

COPY ./overlay /
COPY ./13/overlay /

ENV \
    # set to "1" to compress backup sql files
    BF_PG_BACKUP_COMPRESS_FILES="0" \
    # the number of days after which backups will be deleted
    BF_PG_BACKUP_KEEP_FOR_DAYS="28"

RUN bf-install

VOLUME [ "/data", "/backup" ]
