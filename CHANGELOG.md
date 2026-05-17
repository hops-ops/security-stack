### What's changed in v0.4.1

* fix: Falcosidekick direct Loki output instead of OTLP logs (by @patrickleet)

  Falcosidekick 2.31 chart does NOT expose an OTLP logs endpoint —
  only traces and metrics. The earlier OTLP-logs config was silently
  dropped on chart parse; the Enabled Outputs line read "[OTLPTraces]"
  without Loki.

  Switching to Falcosidekick's native loki output via
  spec.observe.lokiEndpoint (default http://loki-gateway.monitoring.svc.cluster.local).
  Now reports "Enabled Outputs: [Loki OTLPTraces]" — structured Falco
  events land in Loki for Grafana query.

  OTLP traces still flow to the Alloy receiver for Tempo correlation.

  Pipe-through-Alloy for enrichment / fan-out is a future iteration.

  Refs [[tasks/security-stack-observe-integration]]


See full diff: [v0.4.0...v0.4.1](https://github.com/hops-ops/security-stack/compare/v0.4.0...v0.4.1)
