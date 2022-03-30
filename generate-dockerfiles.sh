#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

BASE_REVISION="4.2.4"
echo "Base: ${BASE_REVISION}"

POSTGRESQL_VERSIONS="12 13 14"
for V in ${POSTGRESQL_VERSIONS} ; do

    echo "PostgreSQL ${V}"

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        BASE_REVISION=${BASE_REVISION} \
        POSTGRESQL_MINOR=${V}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

done

docker system prune -f
echo "Done."
