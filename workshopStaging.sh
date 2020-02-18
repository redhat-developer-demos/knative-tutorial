#!/bin/bash

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
rm -rf ./staging-gh-pages .cache

antora --pull --stacktrace  staging.yaml

open staging-gh-pages/index.html