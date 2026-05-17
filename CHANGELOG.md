### What's changed in v0.4.0

* feat: ObserveStack integration toggle (spec.observe.enabled) (by @patrickleet)

  When spec.observe.enabled is true (default):
    - Trivy ServiceMonitor enabled
    - Falco metrics endpoint exposed + ServiceMonitor created (chart uses
      `serviceMonitor.create`, NOT `enabled` — different from falcosidekick)
    - Falcosidekick enabled with OTLP outputs to alloyReceiverEndpoint
      (default http://alloy-receiver.monitoring.svc.cluster.local:4318):
        - logs   → /v1/logs   → Loki via Alloy pipeline
        - traces → /v1/traces → Tempo via Alloy pipeline (syscall source only)
    - Falcosidekick ServiceMonitor created
    - Kubescape capabilities.prometheusExporter flipped to enable, AND
      kubescape.serviceMonitor.enabled set (chart gates SM on both)

  Pat-local platform Prometheus uses empty serviceMonitorSelector{} so no
  release-label requirement.

  Adds 3 KCL tests (15 total): observe-default-enables-telemetry,
  observe-disabled-turns-off-telemetry, observe-alloy-endpoint-override.

  Out of scope for this iteration:
    - PrometheusRule alerts (next iteration)
    - GrafanaDashboard CRs (next iteration)
    - Auto-discovery of alloy endpoint from ObserveStack XR status
    - Tempo trace correlation tuning

  Implements first half of [[tasks/security-stack-observe-integration]]


See full diff: [v0.3.0...v0.4.0](https://github.com/hops-ops/security-stack/compare/v0.3.0...v0.4.0)
