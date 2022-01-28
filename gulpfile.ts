import { BuildTasks } from './build-tasks'
import yargs = require('yargs')

const buildConfig = yargs.options("playbook", {
  alias: 'p',
  default: 'dev-site.yml',
  describe: 'Antora Playbook file to use to build the site'
}).options("srcDir", {
  alias: 's',
  default: '/usr/src/app',
  describe: 'The documentation source root'
}).options("outputDir", {
  alias: 'o',
  default: 'gh-pages',
  describe: 'The site generation path relative to source root'
}).options("cacheDir", {
  alias: 'c',
  default: '.cache',
  describe: 'The Antora Cache directory'
}).argv;

let buildTasks = new BuildTasks(buildConfig);
buildTasks.configure();