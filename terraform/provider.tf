provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.token.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

data "aws_eks_cluster_auth" "token" {
  name = module.eks.cluster_name
}
