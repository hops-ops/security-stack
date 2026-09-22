### What's changed in v0.8.6

* fix(deps): update helm release falco to v9.2.0 (by @renovate[bot])

  XR-rendered Falco chart pin 9.1.0→9.2.0 (appVersion 0.44.1→0.45.0). Values keys we set (driver.kind=modern_ebpf, collectors.kubernetes, falcosidekick/observe paths) remain compatible; chart includes modern_ebpf config.d fix. validate/test/e2e/publish green.


See full diff: [v0.8.5...v0.8.6](https://github.com/hops-ops/security-stack/compare/v0.8.5...v0.8.6)
