#!/bin/sh
docker run -v `pwd`:/antora --rm -t antora/antora:2.0.0 --pull --stacktrace site.yml
open gh-pages/index.html
