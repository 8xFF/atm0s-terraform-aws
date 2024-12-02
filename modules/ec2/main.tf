## Create ec2 standard instance
resource "aws_instance" "standard_instance" {
  count = var.number_standard_instances
  ami   = "ami-0f935a2ecd3a7bd5c" // Amazon Linux 2 AMI Amazon Linux 2023 x86_64 HVM gp2
  // ami = "ami-01b63585f8cb40b9a" // Amazon Linux 2 AMI Amazon Linux 2023 arm HVM gp2
  instance_type   = var.standard_instance_type
  key_name        = var.keypair_name
  subnet_id       = var.public_subnet_id
  security_groups = [var.public_security_group_id]
  tags = {
    Name = "standard-instance-${count.index}"
  }

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
  EOF
}

resource "aws_instance" "media_instance" {
  count = var.number_media_instances
  ami   = "ami-0f935a2ecd3a7bd5c" // Amazon Linux 2 AMI Amazon Linux 2023 x86_64 HVM gp2
  // ami = "ami-01b63585f8cb40b9a" // Amazon Linux 2 AMI Amazon Linux 2023 arm HVM gp2
  instance_type   = var.media_instance_type
  key_name        = var.keypair_name
  subnet_id       = var.public_subnet_id
  security_groups = [var.public_security_group_id]
  tags = {
    Name = "media-instance-${count.index}"
  }

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
  EOF
}
