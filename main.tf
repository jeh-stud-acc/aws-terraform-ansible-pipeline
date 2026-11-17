resource "aws_instance" "my_instance" {
  ami           = "ami-0d27e0fb3bac4d724"
  instance_type = "t3.micro"
  key_name = "key-pair"

  root_block_device {
    volume_size = 10
  }

  ebs_block_device {
    volume_size = 10
    device_name = "/dev/sdf"
  }

  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  tags = {
    Name = "JohnsInstance", Lab7 = "completed"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  referenced_security_group_id = "sg-0051e6f0571d0ccf1"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

output "instance_ip" {
  value = aws_instance.my_instance.private_ip
}