resource "helm_release" "argoCD" {
  depends_on       = [module.eks]
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "10.3.3"
  timeout          = 600

  set = [
    {
      name  = "service.type"
      value = "ClusterIP"
    }
  ]
}