#!/bin/sh

IMAGE=postgresql
VERSION=`cat VERSION`
POSTGRESQL=${1:-18}
TAG=${IMAGE}-test

docker buildx build \
    --load \
    --build-arg BF_IMAGE=${IMAGE} \
    --build-arg BF_VERSION=${VERSION} \
    -f ${POSTGRESQL}/Dockerfile \
    -t ${TAG} \
    . \
    && \
    docker run --entrypoint /test ${TAG}
