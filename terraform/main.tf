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



# resource "kubectl_manifest" "AppProject" {
#     yaml_body = <<YAML
# apiVersion: argoproj.io/v1alpha1
# kind: AppProject
# metadata:
#   name: my-project
#   namespace: argocd
# spec:
#   roles:
#   # A role which provides read-only access to all applications in the project
#   - name: read-only
#     description: Read-only privileges to my-project
#     policies:
#     - p, proj:my-project:read-only, applications, get, my-project/*, allow
#     groups:
#     - my-oidc-group
# YAML
# }