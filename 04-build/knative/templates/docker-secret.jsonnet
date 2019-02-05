local lib = import 'library-ext.libjsonnet';
{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: 'basic-user-pass',
    annotations: {
      'build.knative.dev/docker-0': 'index.docker.io/v1/',
    },
  },
  type: 'kubernetes.io/basic-auth',
  stringData: {
    // the docker registry user name
    username: std.extVar('user'),
    // the docker registry user name
    password: std.extVar('password'),
  },
}
