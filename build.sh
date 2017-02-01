#!/bin/bash

set -e

if [ "x${BUILD_PLATFORM}" == "x" ]; then
    echo "!!! BUILD_PLATFORM not set, exiting."
    exit 2
fi

OMNIBUS_COMMIT=$(git rev-parse HEAD)

if [ "$(git describe --tags --exact-match "$OMNIBUS_COMMIT")" ]; then
    # sort=-v:refname will reverse sort tags, treating them as versions, on git 2.0 and later
    OMNIBUS_TAG=$(git tag -l --points-at HEAD --sort=-v:refname | awk 'NR==1{print $1}')
    SENSU_VERSION=$(echo "$OMNIBUS_TAG" | awk -F'-' '{print $1}' | sed 's/v//g')
    BUILD_NUMBER=$(echo "$OMNIBUS_TAG" | awk -F'-' '{print $2}')

    export SENSU_VERSION BUILD_NUMBER

    if [[ "x$SENSU_VERSION" != "x" ]] && [[ "x$BUILD_NUMBER" != "x" ]]; then
       echo "============================ Building ${SENSU_VERSION}-${BUILD_NUMBER} on ${BUILD_PLATFORM} ============================"

       if [[ "x$TRAVIS_WAIT" == "x" ]] ; then
           bundle exec rake kitchen:default-"$BUILD_PLATFORM"
       else
           # shellcheck source=.travis/functions.sh
           source "$TRAVIS_BUILD_DIR/.travis/functions.sh"
           travis_wait "$TRAVIS_WAIT" bundle exec rake kitchen:default-"$BUILD_PLATFORM"
       fi
    else
        echo "!!! Failed to parse tag \"$OMNIBUS_TAG\" into version ($SENSU_VERSION) and build number ($BUILD_NUMBER)"
        exit 2
    fi
else
    echo "!!! Commit ${OMNIBUS_COMMIT} is not tagged, exiting."
    exit 2
fi
