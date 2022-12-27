variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instancetype" {
  description = "instance type"
  type        = list(string)
  default     = ["t2.micro", "t3.micro"]

}

variable "sshkey" {
  description = "ssh key"
  type        = string
  default     = "aws"

}