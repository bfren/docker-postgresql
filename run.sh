#!/bin/sh

IMAGE=`cat VERSION`
POSTGRESQL=${1:-18}

docker buildx build \
    --load \
    --progress plain \
    --build-arg BF_IMAGE=postgresql \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${POSTGRESQL}/Dockerfile \
    -t postgresql${POSTGRESQL}-dev \
    . \
    && \
    docker run -it \
        -e BF_DEBUG=1 \
        -e BF_PG_APPLICATION=test \
        postgresql${POSTGRESQL}-dev \
        sh

        #-v /tmp/pg-data:/data \
