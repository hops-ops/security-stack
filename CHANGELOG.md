### What's changed in v0.6.0

* fix: bump falco memory limit from 1Gi to 2Gi (by @patrickleet)

  1Gi default OOMKills repeatedly under modest load on pat-local — the
  userspace rule engine plus Lua plugin scratch space outgrows it within
  hours. 2Gi gives headroom; raise further via spec.falco.values.resources
  for larger clusters.

* feat: resource defaults for trivy-operator (by @patrickleet)

  P95 observed at 439Mi on pat-local while running BestEffort. Bump to
  512Mi request==limit (memory protection) with 100m CPU request, no CPU
  limit.

  Implements [[tasks/cluster-wide-resource-right-sizing-p95-observation]] tier-1 #3

* :  (by @patrickleet)

* feat: Burstable resource defaults for falcosidekick + k8s-metacollector (by @patrickleet)

  Both falco subchart components shipped BestEffort by default. Sized for
  small-to-medium clusters; override via spec.falco.values for larger
  event volume.

  Verified on pat-local:
  - falco-falcosidekick (2 replicas) → Burstable, mem-lim=128Mi
  - falco-k8s-metacollector → Burstable, mem-lim=256Mi

  Implements [[tasks/cluster-wide-resource-right-sizing-p95-observation]] tier-1 #8

* feat: Burstable resource defaults for trivy-operator (by @patrickleet)

  Chart 0.30.0 (and 0.32.x) reads top-level resources: for the operator
  Deployment — operator.resources is silently ignored (which is why the
  earlier attempt in c61161e was a no-op and got reverted in f0c997f).

  P95 observed at 439Mi on pat-local while running BestEffort. Sized to
  100m/512Mi req, 512Mi mem limit. Burstable: stateless operator caching
  scan reports; restart-cheap.

  Verified on pat-local: trivy-operator-dc46cdd6c-95wbl rolled to
  Burstable, mem-lim=512Mi after helm upgrade.

  Implements [[tasks/cluster-wide-resource-right-sizing-p95-observation]] tier-1 #3

* fix: bump trivy-operator memory to 1Gi and add scanner resources (by @patrickleet)

  trivy-operator P95 observed at 638Mi on pat-local — the initial 512Mi
  limit OOMKilled under scan churn. Bumped to 1Gi.

  Also set trivy.resources for the scan job containers: chart default
  100m/100M req, 500m/500M limit OOMKilled on real-world images (anything
  larger than ~300MB unpacked). Bumped to 256Mi req, 1Gi limit to handle
  typical platform images.

  Verified on pat-local: trivy-operator-8cb478d7-rhmpl → Burstable,
  mem-lim=1Gi; scan-vulnerabilityreport pods initializing without OOM.

* feat(deps): update crossplane-contrib/function-auto-ready docker tag to v0.6.5 (#4) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>


See full diff: [v0.5.0...v0.6.0](https://github.com/hops-ops/security-stack/compare/v0.5.0...v0.6.0)
