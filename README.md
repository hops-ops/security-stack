# security-stack

Installs **Trivy Operator** (image / IaC / k8s-config / RBAC / exposed-secret scanning)
and **Falco** (eBPF runtime threat detection) on a target Kubernetes cluster via two
Helm Releases.

Cloud-neutral. Group: `hops.ops.com.ai`.

Designed to ride on [policy-stack] — supply-chain ClusterPolicies / CEL
`ImageValidatingPolicy` resources (added in future iterations) compose against the
Kyverno engine that stack installs.

## What's included

- **Trivy Operator** — runs Trivy as a controller that produces
  `VulnerabilityReport`, `ConfigAuditReport`, `RbacAssessmentReport`,
  `ExposedSecretReport` CRs against workloads in the cluster.
- **Falco** — DaemonSet that watches kernel syscalls via eBPF and raises events
  against a configurable ruleset. Ships with the standard Falco rules.

## What's NOT (yet) included

This first iteration is **engine only**. Each of the following lands as a
separate, individually tracked iteration — most are already broken out in GitKB
under `tasks/security-stack-*`:

- Falcosidekick output routing (Loki / OTel collector / SIEM)
- Trivy supply-chain hardening (image digest pinning, cosign-verify-the-scanner,
  CVE-2026-33634 mitigations)
- Cosign v3 baseline + CEL `ImageValidatingPolicy` resources
- Scan-result enforcement via Policy Reporter Trivy plugin (replaces broken
  `apiCall`-based pattern)
- OpenVEX consumption + VSA pattern
- Kubescape posture scanning (complementary to Trivy)
- ObserveStack integration (ServiceMonitors, GrafanaDashboards, PrometheusRule,
  Falcosidekick → Alloy OTel receiver wiring)

## Minimal usage

```yaml
apiVersion: hops.ops.com.ai/v1alpha1
kind: SecurityStack
metadata:
  name: security
  namespace: default
spec:
  clusterName: my-cluster
```

## Standard usage

```yaml
apiVersion: hops.ops.com.ai/v1alpha1
kind: SecurityStack
metadata:
  name: security
  namespace: pat-local
spec:
  clusterName: pat-local
  trivy:
    namespace: trivy-system
  falco:
    namespace: falco
    driver: modern_ebpf
    values:
      resources:
        requests: { cpu: 250m, memory: 512Mi }
        limits:   { cpu: 1000m, memory: 1Gi }
```

## Defaults of note

- **Falco driver**: `modern_ebpf` — legacy `ebpf` deprecated in Falco 0.43; spec
  forbids it.
- **Falco resources**: 256m CPU / 512Mi memory request, 1Gi memory limit. Tunable
  upward via `spec.falco.values.resources`.
- **Falcosidekick**: disabled by default. Output routing (Loki / OTel) is its own
  iteration.
- **Trivy targets**: vulnerabilities + config-audits + rbac-assessment +
  exposed-secrets. Override via `spec.trivy.values`.

## Local testing

```bash
make render:all         # render both examples
make validate:all       # render + schema-validate
make test               # KCL unit tests
hops config install --path .   # install on colima
```

Apply a SecurityStack manifest and watch:

```bash
kubectl get securitystacks -A
kubectl get releases.helm.m.crossplane.io
kubectl get pods -n trivy-system
kubectl get pods -n falco
kubectl get vulnerabilityreports -A
```

## References

- Spec: [specs/security-stack] in GitKB
- Related task: [tasks/security-stack-install] in GitKB
- Trivy Operator: https://aquasecurity.github.io/trivy-operator/
- Falco: https://falco.org/docs/
- Pairs with: [policy-stack]
