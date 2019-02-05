local lib = import 'library-ext.libjsonnet';
{
  apiVersion: ' build.knative.dev/v1alpha1',
  kind: 'BuildTemplate',
  metadata: {
    name: 'maven-build',
  },
  spec: {
    parameters: [
      {
        name: 'IMAGE',
        description: |||
          The name of the image to push.
        |||,
        default: std.extVar('image'),
      },
      {
        name: 'DOCKERFILE',
        description: |||
          Path to the Dockerfile to build.
        |||,
        default: '/workspace/04-build/java/Dockerfile',
      },
      {
        name: 'CACHE',
        description: |||
          The name of the volume for caching Maven artifacts.
        |||,
        default: std.extVar('mavenCachePvc'),
      },
    ],
    steps: [
      {
        name: 'build-maven',
        image: 'gcr.io/cloud-builders/mvn',
        args: [
          'clean',
          'package',
          "-Duser.home='/builder/home'",
        ],
        workingDir: '/workspace/04-build/java',
      },
      {
        name: 'docker-push',
        image: 'gcr.io/kaniko-project/executor',
        args: [
          '--dockerfile=${DOCKERFILE}',
          '--destination=${IMAGE}',
        ],
      },
    ],
  },
  volumes: [
    {
      name: 'm2-cache',
      persistentVolumeClaim: {
        claimName: '${CACHE}',
      },
    },
  ],
}
