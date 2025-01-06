variable "vpc_cidr" {}

variable "subnet_az" {} 

variable "subnet_cidr_block" {}

variable "edit_routes_dest_cidr" {}

variable "sg_name" {} 

variable "desc" {}

variable "environment" {}

variable "ami_id" {}

variable "instance_type" {}

variable "instance_names" {
    description = "aws instances"  
    type = list(string) 
}                  

variable "instance_name" {
    description = "instamnce sfagsg"
    type= string 
    default = "main-server"
}

variable "vpc_cidrs" {
    description = "vpc cidr"
    type = string
    default = "0.0.0.0/10"
}

variable "user_names" {
    description = "iam users"
    type = list(string)
   
}

variable "s3_bucket_names" {
    description = "s3 bucket names"
    type = list(string)
}



variable "aws_ec2_instances" {
    description = "my aws ec2 instances"
    type = list(string)
    default = ["web", "backend", "db"]
}
