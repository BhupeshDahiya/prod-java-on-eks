# Fetch all available azs
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  # Dynamically select 3 azs
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Single nat gateway to save costs
  enable_nat_gateway = true
  single_nat_gateway = true

  # Igw for pub sub
  create_igw = true

  # DNS resolution required by EKS, usually enabled by default
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Optional for security/obserability
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

  # Mandatory tags so that EKS knows which subnets to use
  public_subnet_tags = {
    "kubernetes.io/role/elb"           = "1"
    "kubernetes.io/cluster/my-cluster" = "shared"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"  = "1"
    "kubernetes.io/cluster/my-cluster" = "shared"
  }
  tags = local.common_tags
}