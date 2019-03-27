local lib = import 'library-ext.libjsonnet';
{
  apiVersion: 'build.knative.dev/v1alpha1',
  kind: 'BuildTemplate',
  metadata: {
    name: 'build-java-maven',
    namespace: 'knativetutorial',
  },
  spec: {
    parameters: [
      {
        name: 'IMAGE',
        description: |||
          The name of the image to push.
        |||,
      },
      {
        name: 'CONTEXT_DIR',
        description: |||
          The context directory from where to run the build.
        |||,
      },
    ],
    steps: [
      {
        name: 'build-maven',
        image: 'gcr.io/cloud-builders/mvn',
        args: [
          'clean',
          'package',
          '-Duser.home=/builder/home',
          '-Dimage=${IMAGE}',
        ],
        workingDir: '/workspace/${CONTEXT_DIR}',
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
      {
        name: 'docker-push',
        image: 'gcr.io/kaniko-project/executor',
        args: [
          // tell kaniko the folder to find artifacts
          '--context=/workspace/${CONTEXT_DIR}',
          // directory of dockerfile
          '--dockerfile=/workspace/${CONTEXT_DIR}/Dockerfile',
          // the container image
          '--destination=${IMAGE}',
        ],
        env: [
          {
            name: 'DOCKER_CONFIG',
            value: '/builder/home/.docker',
          },
        ],
        workingDir: '/workspace/${CONTEXT_DIR}',
        volumeMounts: [
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
