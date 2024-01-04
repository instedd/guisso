#!/bin/bash
set -eo pipefail

source <(curl -s https://raw.githubusercontent.com/manastech/ci-docker-builder/0084f2bbc0626341bd29f4f3dc13272f5d27d4ca/build.sh)

dockerSetup
echo $VERSION > VERSION
dockerBuildAndPush
