import { remove } from "fs-extra"
import { readFileSync, readFile, writeFileSync } from "fs";
import { task, series, watch } from 'gulp'
import * as generator from "@antora/site-generator-default"
import { resolve } from "path"
import { load } from "js-yaml"
import { create, BrowserSyncInstance } from "browser-sync"


interface BuildConfig {
  srcDir: string;
  outputDir: string;
  playbook: string;
  cacheDir: string;
  [x: string]: unknown;
  $0: string;
  _: string[];
}

//Antora Published Site info
interface PublishedSite {
  provider: string;
  path: string;
  resolvedPath: string;
  fileUri: string;
}

export class BuildTasks {
  protected buildConfig: BuildConfig;
  cleanBuild: string[] = ["cleanCache", "cleanSite", "build"];
  devMode: string[] = ["clean", "build", "serve", "watch"];
  cleanAll: string[] = ["cleanCache", "cleanSite"];

  siteOutDir: string;
  playbookFile: string;
  watchGlobs: string[];

  server: BrowserSyncInstance;

  constructor(buildConfig: BuildConfig) {
    this.buildConfig = buildConfig;
    this.siteOutDir = resolve(`${buildConfig.srcDir}/${buildConfig.outputDir}`);
    this.playbookFile = resolve(`${buildConfig.srcDir}/${buildConfig.playbook}`);
    this.watchGlobs = this.parsePlaybook();
    this.server = create();
  }

  public configure() {
    //individual tasks
    task("cleanCache", this.cleanCache.bind(this));
    task("cleanSite", this.cleanSite.bind(this));
    task("serve", this.serve.bind(this));
    task("build", this.build.bind(this));
    task("reload", this.reload.bind(this));
    task("watch", this.watch.bind(this));
    //chained tasks
    task("clean", series(this.cleanAll));
    task("cleanBuild", series(this.cleanBuild));
    task("default", series(this.devMode));
  }

  cleanCache(cb: Function) {
    remove(this.buildConfig.cacheDir)
      .then(() => cb())
      .catch(err => console.log("Error cleaning cache directory", err));
  }

  cleanSite(cb: Function) {
    remove(this.buildConfig.cacheDir)
      .then(() => cb())
      .catch(err => console.log("Error cleaning site directory ", err));
  }

  build(cb: Function) {
    console.log(`Building site ${this.playbookFile}`);
    const args: string[] = ["--playbook", this.playbookFile, "--redirect_facility", "static"]
    generator(args, process.env)
      .then((ps) => {
        this.patchIndexFile(ps);
        cb();
      }).catch(err => {
        console.log("Error building site ", err);
        cb();
      });
  }

  serve(cb: Function) {
    this.server.init({
      open: false,
      host: "0.0.0.0",
      server: {
        baseDir: this.siteOutDir
      }
    }, () => {
      cb();
    });

  }

  reload(cb: Function) {
    this.server.reload()
    cb();
  }

  watch(cb: Function) {
    watch(this.watchGlobs, series("build", "reload"))
  }

  private patchIndexFile(ps: PublishedSite[]): void {
    //console.log(JSON.stringify(ps));
    const indexFile = `${ps[0].resolvedPath}/index.html`;
    //console.log("Index file:", indexFile);
    readFile(indexFile, "utf8", (err, data) => {
      if (err) {
        console.log(err);
      }
      let fileC = data;
      fileC = fileC.replace(/^(<script>location=)(.*)(<\/script>)/gm, "\$1\$2 + window.location.search \$3");
      writeFileSync(indexFile, fileC);
    });
  }

  private parsePlaybook(): string[] {
    let json_content = readFileSync(this.playbookFile, "utf-8");
    let yaml_content = load(json_content);
    let dirs = yaml_content.content.sources.map(source => {
      return [
        resolve(`${source.url}/**/*.yml`),
        resolve(`${source.url}/**/*.hbs`),
        resolve(`${source.url}/**/*.adoc`)
      ]
    });
    dirs.push(this.playbookFile)
    dirs = [].concat(...dirs);
    //console.log(dirs);
    return dirs;
  }
}