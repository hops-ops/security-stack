# security-stack

Installs **Trivy Operator** (workload vuln / IaC / RBAC / exposed-secret / SBOM
scanning), **Falco** (eBPF runtime threat detection), and **Kubescape** (CNCF
Incubating posture + framework reports + per-node CIS via DaemonSet host-scanner)
on a target Kubernetes cluster via three Helm Releases.

Cloud-neutral. Group: `hops.ops.com.ai`.

Designed to ride on [policy-stack] — supply-chain ClusterPolicies / CEL
`ImageValidatingPolicy` resources (added in future iterations) compose against the
Kyverno engine that stack installs.

## What's included

- **Trivy Operator** — runs Trivy as a controller that produces
  `VulnerabilityReport`, `ConfigAuditReport`, `RbacAssessmentReport`,
  `ExposedSecretReport`, `SbomReport` CRs against workloads in the cluster.
- **Falco** — DaemonSet that watches kernel syscalls via eBPF and raises events
  against a configurable ruleset. Ships with the standard Falco rules.
- **Kubescape** — CNCF Incubating posture scanner. Operator + DaemonSet
  `host-scanner` (works on EKS Auto Mode where Trivy's per-node Job-with-hostname-
  selector wedges). Produces framework reports against NSA, MITRE ATT&CK, CIS.
  Capabilities are pre-tuned to complement Trivy + Falco + Kyverno: vuln scan /
  runtime detection / admission controller all disabled to avoid double-coverage.

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
  kubescape:
    namespace: kubescape
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
kubectl get pods -n trivy-system -n falco -n kubescape
kubectl get vulnerabilityreports -A          # Trivy
kubectl get configauditreports -A            # Trivy
kubectl get sbomreports -A                   # Trivy
kubectl get exposedsecretreports -A          # Trivy
kubectl get clusterinfraassessmentreports    # Trivy (or Kubescape on Auto Mode)
kubectl get applicationprofiles -A           # Kubescape
kubectl get workloadconfigurationscans -A    # Kubescape
```

## References

- Spec: [specs/security-stack] in GitKB
- Related task: [tasks/security-stack-install] in GitKB
- Trivy Operator: https://aquasecurity.github.io/trivy-operator/
- Falco: https://falco.org/docs/
- Kubescape: https://kubescape.io/docs/
- Pairs with: [policy-stack]
