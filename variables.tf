variable "region" {
  description = "AWS region"
  type        = string
}

variable "az" {
  description = "AWS availability zones"
  default     = ["a", "b"]
}

variable "vpc_cidr" {
  description = "VPC cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = 1.24
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default = {
    "Terraform" = true
    "Project"   = "sifchain"
  }
}

variable "desired_capacity" {
  description = "Desired nodes per cluster for node group main-0"
  default     = 1
}

variable "max_capacity" {
  description = "Max nodes per cluster for node group main-0"
  default     = 1
}

variable "min_capacity" {
  description = "Min nodes per cluster for node group main-0"
  default     = 1
}

variable "ami_type" {
  default = "AL2_ARM_64"
}

variable "disk_size" {
  default = 5
}

variable "profile" {
  description = "AWS profile settings"
  default     = "default"
}

variable "instance_type" {
  description = "The instance_type of the node_group for the eks cluster"
  type        = list(string)
}

variable "account_id" {
  description = "The instance_type of the node_group for the eks cluster"
  type        = string
}
