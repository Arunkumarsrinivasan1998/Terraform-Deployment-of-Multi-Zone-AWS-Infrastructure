resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_block

}

resource "aws_subnet" "mysubnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "mysubnet2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet2_cidr_block
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "myinternetgateway" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "myroutetable" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myinternetgateway.id
  }
}

resource "aws_route_table_association" "myrta1" {
  route_table_id = aws_route_table.myroutetable.id
  subnet_id      = aws_subnet.mysubnet1.id
}

resource "aws_route_table_association" "myrta2" {
  route_table_id = aws_route_table.myroutetable.id
  subnet_id      = aws_subnet.mysubnet2.id
}

resource "aws_security_group" "mysecuritygroup1" {
  name        = "web-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    name = "web-sg"
  }

}

resource "aws_s3_bucket" "mys3bucket" {
  bucket = "mys3bucket-arunprojectchennai"
}

resource "aws_instance" "webserver1" {
  ami                    = "ami-0cd59ecaf368e5ccf"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysecuritygroup1.id]
  subnet_id              = aws_subnet.mysubnet1.id
  user_data              = base64encode(file("userpage.sh"))

}

resource "aws_instance" "webserver2" {
  ami                    = "ami-0cd59ecaf368e5ccf"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysecuritygroup1.id]
  subnet_id              = aws_subnet.mysubnet2.id
  user_data              = base64encode(file("userpage1.sh"))

}

resource "aws_lb" "mylb" {
  name               = "mylb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mysecuritygroup1.id]
  subnets            = [aws_subnet.mysubnet1.id, aws_subnet.mysubnet2.id]

  enable_deletion_protection = true
  tags = {
    Name = "web-lb"
  }
}

resource "aws_lb_target_group" "mylbtg" {
  name     = "mylbtg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }

}

resource "aws_lb_target_group_attachment" "mylbtga" {
  target_group_arn = aws_lb_target_group.mylbtg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "mylbtga2" {
  target_group_arn = aws_lb_target_group.mylbtg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "mylbl" {
  load_balancer_arn = aws_lb.mylb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.mylbtg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.mylb.dns_name
}
