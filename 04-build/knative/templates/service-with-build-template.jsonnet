local lib = import 'library-ext.libjsonnet';

{
  apiVersion: 'serving.knative.dev/v1alpha1',
  kind: 'Service',
  metadata: {
    name: 'event-greeter',
  },
  spec: {
    runLatest: {
      configuration: {
        build: {
          apiVersion: 'build.knative.dev/v1alpha1',
          kind: 'Build',
          spec: {
            serviceAccountName: 'build-bot',
            timeout: '20m',
            source: {
              git: {
                url: 'https://github.com/redhat-developer-demos/knative-tutorial-event-greeter.git',
                revision: 'v0.0.2',
              },
            },
            template: {
              name: 'build-java-maven',
              arguments: [
                { name: 'IMAGE', value: std.extVar('image') },
                { name: 'CONTEXT_DIR', value: std.extVar('contextDir') },
              ],
            },
          },
        },
        revisionTemplate: {
          metadata: {
            labels: {
              app: 'event-greeter',
            },
          },
          spec: {
            container: {
              image: std.extVar('image'),
            },
          },
        },
      },
    },
  },
}
