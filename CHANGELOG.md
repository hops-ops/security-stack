### What's changed in v0.1.0

* feat: initial scaffold — Trivy Operator + Falco helm releases (by @patrickleet)

  Cloud-neutral security stack riding on policy-stack. First pass installs
  Trivy Operator + Falco as helm releases with sane defaults (modern_ebpf,
  falcosidekick off, no policies). Supply-chain ClusterPolicies, scan-result
  enforcement, sidekick OTel wiring, and observe-stack integration ship in
  subsequent iterations.

  Validated end-to-end on colima → pat-local EKS:
  - SecurityStack default/pat-local Ready=True
  - Trivy producing VulnerabilityReport CRs across the cluster
  - Falco DS deployed (partial node coverage — cluster capacity issue,
    not a stack issue)

  wait: false on Falco — DaemonSet readiness depends on per-node pod
  capacity; wait: true wedges on full nodes.

  Implements [[tasks/security-stack-install]]


