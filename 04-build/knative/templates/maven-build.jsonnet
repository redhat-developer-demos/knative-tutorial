local lib = import 'library-ext.libjsonnet';
{
  apiVersion: 'build.knative.dev/v1alpha1',
  kind: 'Build',
  metadata: {
    name: 'maven-build',
  },
  spec: {
    serviceAccountName: 'build-bot',
    timeout: '20m',
    source: {
      git: {
        url: 'https://github.com/kameshsampath/knative-build-test.git',
        revision: 'master',
      },
    },
    steps: [
      {
        name: 'build-maven',
        image: 'gcr.io/cloud-builders/mvn',
        args: [
          'clean',
          'package',
          "-Duser.home='/builder/home'",
        ],
        workingDir: "/workspace/" + std.extVar('contextDir'),
        // to make subsequent builds faster
        volumeMounts: [
          {
            name: 'm2-cache',
            mountPath: '/builder/home/.m2',
            subPath: 'm2-cache',
          },
        ],
      },
      {
        name: 'docker-push',
        image: 'gcr.io/kaniko-project/executor',
        args: [
          "--dockerfile=/workspace/Dockerfile",
          "--destination="+ std.extVar('image'),
        ],
        workingDir: "/workspace/" + std.extVar('contextDir'),
      },
    ],
    volumes: [
      {
        name: 'm2-cache',
        persistentVolumeClaim: {
          claimName: 'm2-cache',
        },
      },
    ],
  },
}
