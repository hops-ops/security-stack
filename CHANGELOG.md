### What's changed in v0.8.4

* fix(deps): update helm release falco to v6.4.1 (by @renovate[bot])

  XR-rendered Falco chart minor. Usage review: modern_ebpf driver, observe-gated metrics + falcosidekick loki/otlp/serviceMonitor paths unchanged; falcosidekick 0.11 only gates grafana dashboard we do not enable. 6.4.1 metrics-map fix aligns with our observe metrics block. validate/test/e2e/publish green.


See full diff: [v0.8.3...v0.8.4](https://github.com/hops-ops/security-stack/compare/v0.8.3...v0.8.4)
