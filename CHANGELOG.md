### What's changed in v0.2.0

* feat: add Kubescape (kubescape-operator chart) as third helm release (by @patrickleet)

  Kubescape brings what Trivy + Falco can't:
    - Per-node CIS via DaemonSet host-scanner (works on EKS Auto Mode where
      Trivy's per-node Job-with-hostname-selector wedges)
    - K8s manifest posture against named frameworks: NSA, MITRE ATT&CK, CIS
    - Workload configuration scans → WorkloadConfigurationScan CRs

  Capabilities pre-tuned to complement (not duplicate) the existing stack:
    ENABLED:  operator, configurationScan, continuousScan, nodeScan
    DISABLED: vulnerabilityScan/relevancy/nodeSbomGeneration (Trivy owns),
              runtimeDetection/malwareDetection/runtimeObservability/
              httpDetection (Falco owns), admissionController (Kyverno owns),
              networkPolicyService/manageWorkloads/seccompProfileService/etc.

  wait: false on the Release — Kubescape's host-scanner is a DaemonSet, same
  per-node-pod-cap rationale as Falco (see reference_helm_wait_for_daemonsets).

  XRD adds spec.kubescape.{enabled,namespace,releaseName,chartVersion,values,
  overrideAllValues}, status.kubescape.ready. Defaults: chart 1.40.1, namespace
  'kubescape', enabled=true. clusterName flows from spec.clusterName for
  Kubescape's multi-cluster discrimination.

  Verified on colima → pat-local EKS Auto Mode: all 3 Releases Ready,
  host-scanner DaemonSet scheduling without restricted-label issues.

  Resolves [[tasks/security-stack-kubescape-promote-v1]]


See full diff: [v0.1.0...v0.2.0](https://github.com/hops-ops/security-stack/compare/v0.1.0...v0.2.0)
