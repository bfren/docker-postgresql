#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

BASE_VERSION="5.6.5"
echo "Base: ${BASE_VERSION}"

POSTGRESQL_VERSIONS="12 13 14 15 16 17"
for V in ${POSTGRESQL_VERSIONS} ; do

    echo "PostgreSQL ${V}"
    ALPINE_EDITION_FILE="${V}/ALPINE_EDITION"
    if [ -f "${ALPINE_EDITION_FILE}" ] ; then
        ALPINE_EDITION=`cat ${ALPINE_EDITION_FILE}`
    else
        ALPINE_EDITION="3.21"
    fi

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        ALPINE_EDITION=${ALPINE_EDITION} \
        BASE_VERSION=${BASE_VERSION} \
        POSTGRESQL_MAJOR=${V}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

done

docker system prune -f
echo "Done."
