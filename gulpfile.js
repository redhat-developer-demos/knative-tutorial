"use strict";

const connect = require("gulp-connect");
const fs = require("fs");
const generator = require("@antora/site-generator-default");
const gulp = require("gulp");
const open = require("gulp-open");
const yaml = require("yaml-js");

let filename = "dev-site.yml";
let args = ["--playbook", filename];

function build(cb) {
  /**
   * Use the '@antora/site-generator-default' node module to build.
   * It's analogous to `$ antora --playbook local-antora-playbook.yml`.
   * Having access to the generator in code may be useful for other
   * reasons in the future (i.e to implement custom features).
   * NOTE: As opposed to building with the CLI, this method doesn't use
   * a separate process for each run. So if a build error occurs with the `gulp`
   * command it can be useful to check if it also happens with the CLI command.
   */
  generator(args, process.env).catch(err => { console.log(err); })
  connect.reload()
  cb();
}

function watch() {
  let json_content = fs.readFileSync(`${__dirname}/${filename}`, "UTF-8");
  let yaml_content = yaml.load(json_content);
  let sources = yaml_content.content.sources.map(source => [
    `${source.url}/**/*.yml`,
    `${source.url}/**/*.adoc`,
    `${source.url}/**/**.hbs`
  ]);
  sources.push(["dev-site.yml"]);
  sources = [].concat.apply([], sources) // Flatten the array
  gulp.watch(sources, build)
}

function serve() {
  connect.server({
    port: 5353,
    name: "Dev Server",
    livereload: true,
    root: "gh-pages"
  });
}

function browse() {
  gulp.src("gh-pages/index.html").pipe(open({uri: 'http://localhost:5353'}))
}

exports.build = build;
exports.default = gulp.parallel(serve, watch, browse)
