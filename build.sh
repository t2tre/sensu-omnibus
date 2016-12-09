#!/bin/bash

set -ev

echo "Beginning build for ${BUILD_PLATFORM}..."

if [ "x${BUILD_PLATFORM}" == "x" ]; then
    echo "BUILD_PLATFORM not set, exiting"
    exit
fi

OMNIBUS_COMMIT=`git rev-parse HEAD`

if [ $(git describe --tags --exact-match $OMNIBUS_COMMIT) ]; then
    TAG_VERSION=`git describe --abbrev=0 --tags | awk -F'-' '{print $1}'`
    TAG_ITERATION=`git describe --abbrev=0 --tags | awk -F'-' '{print $2}'`
    export SENSU_VERSION=$TAG_VERSION
    export BUILD_NUMBER=$TAG_ITERATION
    export KITCHEN_LOCAL_YAML=.kitchen.cloud.yml
    echo "Build artifact will be published as ${version}-${iteration}"
    bundle exec rake kitchen:default-$BUILD_PLATFORM
else
    echo "Commit ${OMNIBUS_COMMIT} is not tagged, exiting."
    exit
fi
