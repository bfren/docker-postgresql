#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

BASE_VERSION="5.0.3"
echo "Base: ${BASE_VERSION}"

POSTGRESQL_VERSIONS="12 13 14 15"
for V in ${POSTGRESQL_VERSIONS} ; do

    echo "PostgreSQL ${V}"

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        BASE_VERSION=${BASE_VERSION} \
        POSTGRESQL_MAJOR=${V}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

done

docker system prune -f
echo "Done."
