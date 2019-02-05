local lib = import 'library-ext.libjsonnet';
{
  apiVersion: 'build.knative.dev/v1alpha1',
  kind: 'Build',
  metadata: {
    name: 'docker-build',
  },
  spec: {
    serviceAccountName: 'build-bot',
    timeout: '20m',
    source: {
      git: {
        url: 'https://github.com/redhat-developer-demos/knative-tutorial-event-greeter.git',
        revision: 'master',
      },
    },
    steps: [
      {
        name: 'docker-push',
        image: 'gcr.io/kaniko-project/executor',
        args: [
          // tell kaniko the folder to find artifacts
          '--context=/workspace/' + std.extVar('contextDir'),
          // directory of dockerfile
          '--dockerfile=/workspace/' + std.extVar('contextDir') + '/Dockerfile',
          // the container image
          '--destination=' + std.extVar('image'),

        ],
        env: [
          {
            name: 'DOCKER_CONFIG',
            value: '/builder/home/.docker',
          },
        ],
        workingDir: '/workspace/' + std.extVar('contextDir'),
        volumeMounts: [
          {
            name: 'm2-cache',
            mountPath: '/builder/home/.m2',
          },
          {
            name: 'kaniko-cache',
            mountPath: '/cache',
          },
        ],
      },
    ],
    volumes: [
      {
        name: 'm2-cache',
        persistentVolumeClaim: {
          claimName: 'm2-cache',
        },
      },
      {
        name: 'kaniko-cache',
        persistentVolumeClaim: {
          claimName: 'kaniko-cache',
        },
      },
    ],
  },
}
