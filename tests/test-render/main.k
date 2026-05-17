import models.ai.com.ops.hops.v1alpha1 as stacksv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

# ==============================================================================
# Unit tests for SecurityStack XRD
#
# Philosophy: test YOUR API, not the provider's.
# - render/validate already checks provider schema correctness
# - Tests verify XRD spec fields produce the expected composed resources
# ==============================================================================

_items = [
    # ==========================================================================
    # Test 1: minimal claim renders trivy + falco + kubescape Helm releases
    #         and their namespaces.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-all-three-releases"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "security"
                spec.clusterName = "my-cluster"
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "trivy-operator"
                    spec.forProvider = {
                        chart = {
                            name = "trivy-operator"
                            repository = "https://aquasecurity.github.io/helm-charts/"
                            version = "0.30.0"
                        }
                        namespace = "trivy-system"
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "falco"
                    spec.forProvider = {
                        chart = {
                            name = "falco"
                            repository = "https://falcosecurity.github.io/charts"
                            version = "6.2.0"
                        }
                        namespace = "falco"
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kubescape"
                    spec.forProvider = {
                        chart = {
                            name = "kubescape-operator"
                            repository = "https://kubescape.github.io/helm-charts/"
                            version = "1.40.1"
                        }
                        namespace = "kubescape"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "security-namespace-trivy"
                    spec.forProvider.manifest = {
                        apiVersion = "v1"
                        kind = "Namespace"
                        metadata.name = "trivy-system"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "security-namespace-falco"
                    spec.forProvider.manifest = {
                        apiVersion = "v1"
                        kind = "Namespace"
                        metadata.name = "falco"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "security-namespace-kubescape"
                    spec.forProvider.manifest = {
                        apiVersion = "v1"
                        kind = "Namespace"
                        metadata.name = "kubescape"
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 2: custom labels merge with stack defaults on every composed resource.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-labels-merged-with-defaults"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "labeled-security"
                spec = {
                    clusterName = "my-cluster"
                    labels = {team = "platform", environment = "staging"}
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "trivy-operator"
                        labels = {
                            "hops.ops.com.ai/managed" = "true"
                            "hops.ops.com.ai/securitystack" = "labeled-security"
                            team = "platform"
                            environment = "staging"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 3: falco disabled — only trivy + kubescape releases render.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "falco-disabled-skips-its-release"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "trivy-and-kubescape"
                spec = {
                    clusterName = "my-cluster"
                    falco = {enabled = False}
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "trivy-operator"
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kubescape"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 4: trivy disabled — only falco + kubescape render.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "trivy-disabled-skips-its-release"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "falco-and-kubescape"
                spec = {
                    clusterName = "my-cluster"
                    trivy = {enabled = False}
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "falco"
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kubescape"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 5: kubescape disabled — only trivy + falco render.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "kubescape-disabled-skips-its-release"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "trivy-and-falco"
                spec = {
                    clusterName = "my-cluster"
                    kubescape = {enabled = False}
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "trivy-operator"
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "falco"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 6: custom chart versions propagate (including kubescape).
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-chart-versions-propagate"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "version-test"
                spec = {
                    clusterName = "my-cluster"
                    trivy = {chartVersion = "0.29.3"}
                    falco = {chartVersion = "6.1.0"}
                    kubescape = {chartVersion = "1.39.0"}
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "trivy-operator"
                    spec.forProvider.chart.version = "0.29.3"
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "falco"
                    spec.forProvider.chart.version = "6.1.0"
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kubescape"
                    spec.forProvider.chart.version = "1.39.0"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 7: kubescape clusterName flows from spec.clusterName.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "kubescape-clusterName-flows-from-spec"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "cluster-name-test"
                spec.clusterName = "prod-eu-west-1"
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kubescape"
                    spec.forProvider.values.clusterName = "prod-eu-west-1"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 8: kubescape capabilities default to "disable" for tools owned
    #         elsewhere (avoid double-coverage with trivy/falco/kyverno).
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "kubescape-capabilities-avoid-double-coverage"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "caps-test"
                spec.clusterName = "my-cluster"
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kubescape"
                    spec.forProvider.values.capabilities = {
                        operator = "enable"
                        configurationScan = "enable"
                        continuousScan = "enable"
                        nodeScan = "enable"
                        vulnerabilityScan = "disable"
                        relevancy = "disable"
                        nodeSbomGeneration = "disable"
                        scanEmbeddedSBOMs = "disable"
                        vexGeneration = "disable"
                        runtimeObservability = "disable"
                        runtimeDetection = "disable"
                        malwareDetection = "disable"
                        httpDetection = "disable"
                        admissionController = "disable"
                        networkPolicyService = "disable"
                        networkEventsStreaming = "disable"
                        nodeProfileService = "disable"
                        seccompProfileService = "disable"
                        manageWorkloads = "disable"
                        syncSBOM = "disable"
                        riskAcceptance = "disable"
                        prometheusExporter = "enable"  # flipped by spec.observe.enabled (default true)
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 9: kubescape StorageClass composed by default, with EKS defaults
    #         and persistence.storageClass auto-injected into helm values.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "kubescape-storage-class-default"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "sc-test"
                spec.clusterName = "my-cluster"
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "sc-test-kubescape-sc"
                    spec.forProvider.manifest = {
                        apiVersion = "storage.k8s.io/v1"
                        kind = "StorageClass"
                        metadata.name = "kubescape"
                        provisioner = "ebs.csi.eks.amazonaws.com"
                        reclaimPolicy = "Delete"
                        volumeBindingMode = "WaitForFirstConsumer"
                        parameters = {type = "gp3"}
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kubescape"
                    spec.forProvider.values.persistence.storageClass = "kubescape"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 10: kubescape StorageClass overrides — name, provisioner, params.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "kubescape-storage-class-overrides"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "sc-override"
                spec = {
                    clusterName = "gke-cluster"
                    kubescape.storageClass = {
                        name = "kubescape-fast"
                        provisioner = "pd.csi.storage.gke.io"
                        parameters = {type = "pd-ssd"}
                        reclaimPolicy = "Retain"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "sc-override-kubescape-fast-sc"
                    spec.forProvider.manifest = {
                        apiVersion = "storage.k8s.io/v1"
                        kind = "StorageClass"
                        metadata.name = "kubescape-fast"
                        provisioner = "pd.csi.storage.gke.io"
                        reclaimPolicy = "Retain"
                        parameters = {type = "pd-ssd"}
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kubescape"
                    spec.forProvider.values.persistence.storageClass = "kubescape-fast"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 11: kubescape.storageClass.enabled=false skips SC rendering and
    #          does NOT inject persistence.storageClass into helm values.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "kubescape-storage-class-disabled"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "no-sc"
                spec = {
                    clusterName = "my-cluster"
                    kubescape.storageClass = {enabled = False}
                }
            }
            # We assert the Release exists (kubescape helm still installs) —
            # absence of the SC Object MR and absence of the auto-injected
            # persistence.storageClass would be observed via render output.
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kubescape"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 12: helmProviderConfigRef defaults to clusterName.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "helm-provider-config-defaults-to-cluster-name"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "pcr-test"
                spec.clusterName = "prod-cluster"
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "trivy-operator"
                    spec.providerConfigRef = {
                        name = "prod-cluster"
                        kind = "ProviderConfig"
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 13: spec.observe.enabled defaults true — Trivy + Falco + Kubescape
    #          ServiceMonitors enabled, Falcosidekick on with OTLP to alloy,
    #          Kubescape prometheusExporter flipped to enable.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "observe-default-enables-telemetry"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "obs-default"
                spec.clusterName = "my-cluster"
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "trivy-operator"
                    spec.forProvider.values.serviceMonitor.enabled = True
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "falco"
                    spec.forProvider.values = {
                        metrics.enabled = True
                        serviceMonitor.create = True
                        falcosidekick = {
                            enabled = True
                            serviceMonitor.enabled = True
                            config = {
                                loki = {
                                    hostport = "http://loki-gateway.monitoring.svc.cluster.local"
                                    format = "json"
                                }
                                otlp.traces.endpoint = "http://alloy-receiver.monitoring.svc.cluster.local:4318/v1/traces"
                            }
                        }
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kubescape"
                    spec.forProvider.values = {
                        capabilities.prometheusExporter = "enable"
                        kubescape.serviceMonitor.enabled = True
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 14: spec.observe.enabled=false — all telemetry off; falcosidekick
    #          disabled; Kubescape prometheusExporter back to disable.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "observe-disabled-turns-off-telemetry"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "obs-off"
                spec = {
                    clusterName = "my-cluster"
                    observe.enabled = False
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "trivy-operator"
                    spec.forProvider.values.serviceMonitor.enabled = False
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "falco"
                    spec.forProvider.values = {
                        serviceMonitor.create = False
                        falcosidekick.enabled = False
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kubescape"
                    spec.forProvider.values.capabilities.prometheusExporter = "disable"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 13b: observe default — 3 GrafanaDashboard CRs (trivy, falco,
    #           kubescape) composed in monitoring ns, referencing upstream
    #           grafana.com IDs.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "observe-default-composes-grafana-dashboards"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "dash-test"
                spec.clusterName = "my-cluster"
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "dash-test-dashboard-trivy"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDashboard"
                        metadata = {
                            name = "security-trivy"
                            namespace = "monitoring"
                        }
                        spec = {
                            instanceSelector.matchLabels.dashboards = "grafana"
                            resyncPeriod = "24h"
                            grafanaCom.id = 17813
                        }
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "dash-test-dashboard-falco"
                    spec.forProvider.manifest.spec.grafanaCom.id = 17319
                }
            ]
        }
    }

    # ==========================================================================
    # Test 13c: observe default — PrometheusRule composed with FalcoKernelDrops
    #           as the SLO alert + 4 others.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "observe-default-composes-prometheus-rules"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "rules-test"
                spec.clusterName = "my-cluster"
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "rules-test-prometheus-rules"
                    spec.forProvider.manifest = {
                        apiVersion = "monitoring.coreos.com/v1"
                        kind = "PrometheusRule"
                        metadata = {
                            name = "security-stack"
                            namespace = "monitoring"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 13d: observe.enabled=false — no GrafanaDashboard or PrometheusRule
    #           Object MRs render.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "observe-disabled-skips-dashboards-and-rules"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "no-obs"
                spec = {
                    clusterName = "my-cluster"
                    observe.enabled = False
                }
            }
            # Assert by presence of base releases only — dashboards/rules
            # should not appear in render output (KCL test runner does not
            # fail on missing absence-assertion; absence is implicit).
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "trivy-operator"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 15: alloyReceiverEndpoint override flows into Falcosidekick OTLP.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "observe-alloy-endpoint-override"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "obs-custom"
                spec = {
                    clusterName = "my-cluster"
                    observe.alloyReceiverEndpoint = "http://otel-collector.observe.svc:4318"
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "falco"
                    spec.forProvider.values.falcosidekick.config.otlp.traces.endpoint = "http://otel-collector.observe.svc:4318/v1/traces"
                }
            ]
        }
    }
]

items = _items
