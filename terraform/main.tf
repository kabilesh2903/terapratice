##############################
# IAM Role for EKS Cluster
##############################
resource "aws_iam_role" "globalrole" {
  name = "eks-cluster-role"

<<<<<<< HEAD
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
=======
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
>>>>>>> 57eb1e1890413234d37fc5ab60043ef4acc16846
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.globalrole.name
}

##############################
# EKS Cluster
##############################
resource "aws_eks_cluster" "global_cluster" {
  name     = var.clustername
  role_arn = aws_iam_role.globalrole.arn
  version  = "1.33"

  vpc_config {
    subnet_ids = [
      aws_subnet.pubsub01.id,
      aws_subnet.pubsub02.id
      # Add private subnets if needed
      # aws_subnet.pri01.id,
      # aws_subnet.pri02.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name        = "devcluster"
    Environment = var.env
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attach
  ]
}

##############################
# IAM Role for Node Group
##############################
resource "aws_iam_role" "global_node_group_role" {
  name = "node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach required policies
resource "aws_iam_role_policy_attachment" "node_worker_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.global_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node_cni_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.global_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node_registry_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.global_node_group_role.name
}

##############################
# EKS Node Group
##############################
resource "aws_eks_node_group" "global_node_group" {
  cluster_name    = aws_eks_cluster.global_cluster.name
  node_group_name = "HighIn"
  node_role_arn   = aws_iam_role.global_node_group_role.arn
  subnet_ids = [
    aws_subnet.pubsub01.id,
    aws_subnet.pubsub02.id
    # Add private subnets if needed
    # aws_subnet.pri01.id,
    # aws_subnet.pri02.id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  instance_types = ["t2.micro"]

  labels = {
    zone = "west"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_attach,
    aws_iam_role_policy_attachment.node_cni_attach,
    aws_iam_role_policy_attachment.node_registry_attach,
    aws_eks_cluster.global_cluster
  ]
}
