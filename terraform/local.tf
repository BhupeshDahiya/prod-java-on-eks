resource "local_file" "alb_app" {
  content = templatefile("${path.module}/../gitops/apps/aws_load_balancer_controller.yaml.tpl", {
    vpc_id       = module.vpc.vpc_id
    cluster_name = module.eks.cluster_name
  })
  filename = "${path.module}/../gitops/apps/aws_load_balancer_controller.yaml"
}
