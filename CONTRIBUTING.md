# Contributing Guide

The sources of this tutorial docs is split across multiple repositories:

- The root repository which integrates all other module repositories to build the tutorial site:
 <http://github.com/redhat-developer-demos/knative-tutorial.git>

## Tutorial Modules

- [Setup](https://github.com/redhat-developer-demos/knative-tutorial/tree/master/documentation/modules/setup)

- [Knative Serving](https://github.com/redhat-developer-demos/knative-tutorial/tree/master/documentation/modules/serving)

- [Knative Eventing](https://github.com/redhat-developer-demos/knative-tutorial/tree/master/documentation/modules/eventing)

- [Camel-K](https://github.com/redhat-developer-demos/knative-tutorial/tree/master/documentation/modules/camelk)

- [Advanced Topics](https://github.com/redhat-developer-demos/knative-tutorial/tree/master/documentation/modules/advanced)

## Running site in development mode

To run the site in development mode you need to have [yarn](https://yarnpkg.com) or [npm](https://nodejs.org/en/) installed with [nodejs](https://nodejs.org) v12.x or above.

After cloning the repositories, you can run the `yarn install` or `npm install` from the `knative-tutorial` repository to install needed nodejs packages.

Start the development site using `gulp -s $PWD` that should make the a local development site available at <http://localhost:3000>.

Making any changes to your local repositories above cloned earlier, will be automatically built and the development site gets reloaded automatically.

## Send your contribution

Now you are all set,

- Open an Issue in <http://github.com/redhat-developer-demos/knative-tutorial.git>
- Prepare your changes in the respective documentation repository
- Send the PR to respective repositories listed above

We try to follow the Git commit messages using <https://www.conventionalcommits.org/en/v1.0.0/> and thats not a hard rule ;)
