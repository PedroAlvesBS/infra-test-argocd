########################################################################
#
#                              Argo CD
#
########################################################################
resource "helm_release" "argocd" {
  name             = "argocd-release"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.35.0"

  values = [
    "${file("values/argo.yaml")}"
  ]
}


########################################################################
#
#                     Project -> Apps of Apps
#
########################################################################
resource "kubectl_manifest" "app_project" {
    yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: main-project
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  description: Testing project
  sourceRepos:
  - '*'
  destinations:
    - namespace: "*"
      server: https://kubernetes.default.svc
      name: in-cluster
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceBlacklist:
    - group: ''
      kind: ResourceQuota
    - group: ''
      kind: LimitRange
    - group: ''
      kind: NetworkPolicy
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
  orphanedResources:
    warn: false
  roles:
  - name: read-only
    description: Read-only privileges to main-project
    policies:
    - p, proj:main-project:read-only, applications, get, main-project/*, allow
    groups:
    - my-oidc-group
YAML
  depends_on = [helm_release.argocd]
}

########################################################################
#
#                    Apps of Apps
#
########################################################################
resource "kubectl_manifest" "apps_of_apps" {
    yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: all-apps
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  labels:
    name:  allApps
spec:
  project: main-project
  source:
    repoURL: https://github.com/PedroAlvesBS/infra-test-argocd.git
    targetRevision: HEAD
    path: argo-cd
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - Validate=true
    - CreateNamespace=true 
    - PruneLast=true
    managedNamespaceMetadata:
      labels:
        managed: argocd
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
YAML
  depends_on = [helm_release.argocd]
}