#vpc creation

resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  tags = {
    Name = "${local.env}-vpc"
  }
}


# internet gateway creation 

resource "aws_internet_gateway" "my_igw" {

  vpc_id = aws_vpc.my_vpc.id
    tags = {
        Name = "${local.env}-igw"
    }
}


# subnet creation 

resource "aws_subnet" "my_subnet" {
    vpc_id = aws_vpc.my_vpc.id 
    
    map_public_ip_on_launch = true

    availability_zone = var.subnet_az 
    cidr_block = var.subnet_cidr_block
    
     tags = {
        Name = "${local.env}-public-subnet1"
    }
}

# route table creation 

resource "aws_route_table" "my_rt" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
      Name = "${local.env}-rt"
    }
}

# aws route table association 

resource "aws_route_table_association" "my_rt_association" {
  route_table_id = aws_route_table.my_rt.id
  subnet_id      = aws_subnet.my_subnet.id
}

# aws edit routes 

resource "aws_route" "my_routes" {
  route_table_id         = aws_route_table.my_rt.id
  destination_cidr_block = var.edit_routes_dest_cidr
  gateway_id             = aws_internet_gateway.my_igw.id
}

# aws security group 

resource "aws_security_group" "my_sg" {
    name = var.sg_name
    vpc_id = aws_vpc.my_vpc.id  
    description = var.desc 

    ingress {
        from_port = 22
        to_port = 22 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH Connection"
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP connection"
    }

     ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP connection"
    }

    
    dynamic "ingress" {
      for_each = local.ingress_rules

      content {
        description = ingress.value.description
        from_port = ingress.value.port 
        to_port = ingress.value.port 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

      }
    }

    tags = {
      Name = "${local.env}-sg"
    }
  
}

resource "aws_instance" "my_ec2" {
  instance_type = var.instance_type   
  ami = var.ami_id 
  subnet_id = aws_subnet.my_subnet.id   
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx
              echo "<h1>Hello from terraform provisioned EC2! </h1>" > /var/www/html/index.html
              EOF
  )
  tags = {
    Name = "${local.env}-server"
  }
  
}


#Example - Count

#resource "aws_instance" "server_count" {
#  count = length(var.instance_names)  
#  ami = var.ami_id
#  instance_type = var.instance_type
#  subnet_id = aws_subnet.my_subnet.id
#
#  tags = {
#    Name = var.instance_names[count.index]  
#  }
#}

resource "aws_iam_user" "my_iam_users" {
  count = length(var.user_names)
  name = var.user_names[count.index]
}

resource "aws_s3_bucket" "my_s3_buckets" {
  count = length(var.s3_bucket_names)
  bucket = var.s3_bucket_names[count.index] 
  tags = {
    Name = var.s3_bucket_names[count.index]
  }
}

# convert the list to set if we use for_each

#resource "aws_instance" "my_ec2_instances" {
#  for_each = toset(var.aws_ec2_instances)
#  ami = var.ami_id
#  instance_type = var.instance_type
#3  subnet_id = aws_subnet.my_subnet.id
#  
#  tags = {
#    Name = "${each.value}-ec2-server"
#  }  
#}

#terraform provisioner 
#file provisioner , local-exec, remote-exec 
#file provisioner can be used for transferring and copyinf file from one machine to another machine

#provisioner "file" {
#  source = "/home/ubuntu/terraform_vpc/index.html"
#  destination = "home/ubuntu/index.html" 
#}

#terraform dynamic_blocks
