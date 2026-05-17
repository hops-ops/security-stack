### What's changed in v0.5.0

* feat: GrafanaDashboard CRs + PrometheusRule with 6 security alerts (by @patrickleet)

  Dashboards (composed when spec.observe.enabled):
    - security-trivy   — Trivy Operator overview (grafana.com/d/17813)
    - security-falco   — Falco metrics + rule firings (grafana.com/d/17319)
    - (Kubescape dashboard deferred — no stable upstream grafana.com ID
      for the OSS prometheus-exporter; gap tracked in
      tasks/security-stack-observe-integration.)

  PrometheusRule `security-stack` with 6 alerts, ordered by
  severity-of-failure-to-detect:

    Falco group:
      - FalcoKernelDrops          (CRITICAL — THE SLO. Dropped kernel events
                                  = lost detections. Silent detection-loss
                                  is the worst failure mode.)
      - FalcoControllerUnavailable (WARNING — DS pods missing on N nodes;
                                  Auto Mode per-node pod cap, taints, etc.)
      - FalcoCriticalRuleFiring   (CRITICAL — any Critical/Emergency Falco
                                  rule firing = active security incident)

    Trivy group:
      - TrivyScanFailing          (WARNING — VulnerabilityReports go stale,
                                  CVE blind spots accumulate silently)
      - TrivyCriticalVulnerability (WARNING — workloads running with CRITICAL
                                  CVEs; Audit signal until admission lands)

    Kubescape group:
      - KubescapePostureRegression (WARNING — cluster_riskScore > 30)

  Both gated on $state.observe.enabled. Both land in `monitoring` namespace
  (same convention as observe-stack opencost dashboards).

  3 new KCL tests (18 total):
    - observe-default-composes-grafana-dashboards
    - observe-default-composes-prometheus-rules
    - observe-disabled-skips-dashboards-and-rules

  Verified on pat-local: dashboards "applied to 1 instances", PrometheusRule
  present with all 6 alerts loaded by Prometheus.

  Implements next half of [[tasks/security-stack-observe-integration]]


See full diff: [v0.4.1...v0.5.0](https://github.com/hops-ops/security-stack/compare/v0.4.1...v0.5.0)
