local lib = import 'library-ext.libjsonnet';

{
  apiVersion: 'serving.knative.dev/v1alpha1',
  kind: 'Service',
  metadata: {
    name: 'event-greeter',
  },
  spec: {
    runLatest: {
      revisionTemplate: {
        metadata: {
          labels: {
            app: 'event-greeter',
          },
        },
      },
      spec: {
        buildRef: {
           apiVersion: 'build.knative.dev/v1alpha1',
           kind: 'Build',
           name: 'maven-build'
        },
        container: {
          image: std.extVar('image'),
        },
      },
    },
  },
}
