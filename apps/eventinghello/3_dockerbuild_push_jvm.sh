#!/bin/bash

VERSION=0.0.2
APP=eventinghello

docker build -t dev.local/rhdevelopers/$APP:$VERSION -f src/main/docker/Dockerfile.jvm .

docker login quay.io

docker tag dev.local/rhdevelopers/$APP:$VERSION quay.io/rhdevelopers/$APP:$VERSION
docker push quay.io/rhdevelopers/$APP:$VERSION

