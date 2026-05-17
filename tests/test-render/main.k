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
    # Test 1: minimal claim renders trivy + falco Helm releases and namespaces.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-both-releases"
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
    # Test 3: falco disabled — only trivy release + its namespace render.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "falco-disabled-skips-its-release"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "trivy-only"
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
            ]
        }
    }

    # ==========================================================================
    # Test 4: trivy disabled — only falco release renders.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "trivy-disabled-skips-its-release"
        spec = {
            compositionPath = "apis/securitystacks/composition.yaml"
            xrdPath = "apis/securitystacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.SecurityStack {
                metadata.name = "falco-only"
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
            ]
        }
    }

    # ==========================================================================
    # Test 5: custom chart versions propagate.
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
            ]
        }
    }

    # ==========================================================================
    # Test 6: helmProviderConfigRef defaults to clusterName.
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
]

items = _items
