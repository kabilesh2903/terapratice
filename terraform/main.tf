# Create VPC using AWS VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project = "versioned-eks"
    Owner   = "Kabilesh"
  }
}

# Create EKS Cluster using AWS EKS Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.3.2"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]

      min_size     = 1
      max_size     = 3
      desired_size = var.desired_capacity

      tags = {
        Name = "default-ng"
      }
    }
  }

  tags = {
    Project = "versioned-eks"
    Env     = "dev"
  }
}
