#!/bin/bash

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
rm -rf ./gh-pages .cache

antora --pull --stacktrace  staging.yaml

open gh-pages/index.html