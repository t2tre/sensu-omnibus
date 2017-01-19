#!/bin/bash

set -e

if [ "x${BUILD_PLATFORM}" == "x" ]; then
    echo "!!! BUILD_PLATFORM not set, exiting."
    exit 2
fi

OMNIBUS_COMMIT=`git rev-parse HEAD`

if [ `git describe --tags --exact-match $OMNIBUS_COMMIT` ]; then
    TAGS=`git tag -l --points-at HEAD`
    TAG_COUNT=`echo $TAGS | tr '[[:space:]]' '\n' | wc -l`

    # Please use unique commits when creating tags to trigger this build
    if [[ "$TAG_COUNT" -ne "1" ]] ; then
        echo "Error: Found multiple tags matching $OMNIBUS_COMMIT : $(echo $TAGS)"
        exit 2
    fi

    export SENSU_VERSION=`git describe --abbrev=0 --tags | awk -F'-' '{print $1}' | sed 's/v//g'`
    export BUILD_NUMBER=`git describe --abbrev=0 --tags | awk -F'-' '{print $2}'`
    echo "============================ Building ${SENSU_VERSION}-${BUILD_NUMBER} on ${BUILD_PLATFORM} ============================"

    if [[ "x$TRAVIS_WAIT" -eq "x" ]] ; then
        bundle exec rake kitchen:default-$BUILD_PLATFORM
    else
        travis_wait $TRAVIS_WAIT bundle exec rake kitchen:default-$BUILD_PLATFORM
    fi
else
    echo "!!! Commit ${OMNIBUS_COMMIT} is not tagged, exiting."
    exit 2
fi
