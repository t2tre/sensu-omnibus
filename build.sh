#!/bin/bash

set -ev

if [ "x${BUILD_PLATFORM}" == "x" ]; then
    echo "BUILD_PLATFORM not set, exiting"
    exit
fi

echo "Beginning build for ${BUILD_PLATFORM}..."

OMNIBUS_COMMIT=`git rev-parse HEAD`

if [ `git describe --tags --exact-match $OMNIBUS_COMMIT` ]; then
    export SENSU_VERSION=`git describe --abbrev=0 --tags | awk -F'-' '{print $1}' | sed 's/v//g'`
    export BUILD_NUMBER=`git describe --abbrev=0 --tags | awk -F'-' '{print $2}'`
    export KITCHEN_LOCAL_YAML=.kitchen.cloud.yml
    echo "Building ${BUILD_PLATFORM} ${SENSU_VERSION}-${BUILD_NUMBER}"
    bundle exec rake kitchen:default-$BUILD_PLATFORM
else
    echo "Commit ${OMNIBUS_COMMIT} is not tagged, exiting."
    exit
fi
