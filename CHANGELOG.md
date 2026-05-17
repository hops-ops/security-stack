### What's changed in v0.3.0

* feat: compose Kubescape StorageClass via spec.kubescape.storageClass (by @patrickleet)

  Removes the dependency on the cluster having a default StorageClass for
  the right CSI driver. Mirrors the knative-stack nats.storageClass pattern.

  XRD adds spec.kubescape.storageClass.{enabled, name, provisioner, parameters,
  reclaimPolicy, volumeBindingMode}. Defaults: name=kubescape, provisioner=
  ebs.csi.eks.amazonaws.com, parameters={type: gp3}, reclaimPolicy=Delete,
  volumeBindingMode=WaitForFirstConsumer.

  When the SC is composed, persistence.storageClass in the kubescape Helm
  values defaults to its name (still overridable via spec.kubescape.values).
  Disable via spec.kubescape.storageClass.enabled=false to fall back to the
  chart's "-" default (uses cluster default SC).

  3 new KCL tests (12/12 total): SC composed by default, overrides flow,
  disabled-skips-rendering.

  Replaces the local/securitystack.yaml `loki` opportunistic override.

  Implements [[tasks/security-stack-install]] follow-up


See full diff: [v0.2.0...v0.3.0](https://github.com/hops-ops/security-stack/compare/v0.2.0...v0.3.0)
