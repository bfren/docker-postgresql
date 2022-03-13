#!/bin/sh

IMAGE=`cat VERSION`
POSTGRESQL=${1:-14}

docker buildx build \
    --build-arg BF_IMAGE=postgresql \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${POSTGRESQL}/Dockerfile \
    -t postgresql${POSTGRESQL}-dev \
    . \
    && \
    docker run -it -e POSTGRESQL_USERNAME=test -e POSTGRESQL_PASSWORD=test postgresql${POSTGRESQL}-dev sh
