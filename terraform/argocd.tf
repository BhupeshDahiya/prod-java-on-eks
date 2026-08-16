resource "helm_release" "argoCD" {
  # We need the nodes up and running so that terraform doesnt try installing argo on nothing
  depends_on       = [module.eks]
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "10.3.3"

  set = [
    {
      name  = "service.type"
      value = "ClusterIP"
    }
  ]
}