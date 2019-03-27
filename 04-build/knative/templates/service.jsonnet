local lib = import 'library-ext.libjsonnet';

{
  apiVersion: 'serving.knative.dev/v1alpha1',
  kind: 'Service',
  metadata: {
    name: 'event-greeter',
    namespace: 'knativetutorial',
  },
  spec: {
    runLatest: {
      configuration: {
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
