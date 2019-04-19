Modifying the tutorial
======================

The tutorial is written in asciidoc and can be updated using any text editor.
You can preview changes as you make them as follows:

1. Install the `antora` website generator and the `gulp` build system
$ npm install @antora/cli @antora/site-generator-default gulp@^3.9.1 gulp-connect yaml-js

2. Create a `dev-site.yml` file (the `site.yml` file is for the public website) with the following contents:

runtime:
  cache_dir: ./.cache/antora

site:
  title: Knative Tutorial
  url: https://redhat-developer-demos.github.io/knative-tutorial
  start_page: knative-tutorial::index.adoc

content:
  sources:
    - url: .
      branches: HEAD
      start_path: documentation

asciidoc:
  attributes:
    tutorial-namespace: knativetutorial
  extensions:
    - ./lib/copy-to-clipboard.js

ui:
  bundle:
    url: https://gitlab.com/antora/antora-ui-default/-/jobs/artifacts/master/raw/build/ui-bundle.zip?job=bundle-stable
    snapshot: true
  supplemental_files: ./supplemental-ui

output:
  dir: ./gh-pages

3. Run `node_modules/.bin/gulp`

This will generate HTML, start a local web server at `localhost:5353`, which you can open in your browser, and automatically update the HTML when the asciidoc source changes. If you are not seeing your source changes reflected in the browser, try cleaning browser cache.
