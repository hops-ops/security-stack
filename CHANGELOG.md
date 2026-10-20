### What's changed in v0.8.8

* fix(deps): update helm release falco to v9.2.1 (#17) (by @renovate[bot])

  XR-rendered chart default (000-state-init chartVersion) -> fix to cut a release.
  9.2.1: Falco 0.45.1 (packaging + file_output fixes), container plugin 0.7.5, ServiceMonitor only when metrics.enabled (we set serviceMonitor.create and metrics.enabled together from observe.enabled, so unchanged), /host/proc mounted read-only for modern_ebpf (our default driver; Falco only reads procfs).
  PR CI: test (render), validate x2, publish green. Note: repo has no e2e test dir, so the chart is not deployed in CI.

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>


See full diff: [v0.8.7...v0.8.8](https://github.com/hops-ops/security-stack/compare/v0.8.7...v0.8.8)
