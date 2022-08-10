variable "ssh_user" {
  type        = string
  description = "The SSH username"
  default     = "ubuntu"
}

variable "key_name" {
  type        = string
  description = "The SSH key name"
  default     = "devops_aws_key"
}

variable "private_key_path" {
  type        = string
  description = "The SSH key file"
  default     = "~/code/terraform-ansible-example/devops_aws_key"
}