# Contributing Guide

The sources of this tutorial docs is split across multiple repositories:

- The root repository which integrates all other module repositories to build the tutorial site:
 http://github.com/redhat-developer-demos/knative-tutorial.git

- Setup and Knative Serving:
 http://github.com/redhat-developer-demos/knative-tutorial-module-serving.git

- Knative Eventing:
 http://github.com/redhat-developer-demos/knative-tutorial-module-eventing.git

- Camel-K based Enterprise Integration chapters:
 http://github.com/redhat-developer-demos/knative-tutorial-module-camelk.git

- Advanced Integration:
 http://github.com/redhat-developer-demos/knative-tutorial-module-advanced.git

## Running site in development mode

To run the site in development mode you need to have [yarn](https://yarnpkg.com) or [npm](https://nodejs.org/en/) installed with [nodejs](https://nodejs.org) v12.x or above.

After cloning the repositories, you can run the `yarn install` or `npm install` from the `knative-tutorial` repository to install needed nodejs packages.

Start the development site using `yarn run dev` or `npm run dev` command, this should open a local development site in http://localhost:3000. 

Making any changes to your local repositories above cloned earlier, will be automatically built and the development site gets reloaded automatically.

## Send your contribution

Now you are all set, 
- Open an Issue in http://github.com/redhat-developer-demos/knative-tutorial.git
- Prepare your changes in the respective documentation repository
- Send the PR to respective repositories listed above

We try to follow the Git commit messages using http://karma-runner.github.io/4.0/dev/git-commit-msg.html and thats not a hard rule ;)
