resource "aws_instance" "console_instance" {
  count                       = var.is_primary_cluster ? 1 : 0
  ami                         = var.ec2_ami
  instance_type               = var.standard_instance_type
  key_name                    = var.keypair_name
  subnet_id                   = var.subnet_ids[0]
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = var.ec2_iam_profile
  associate_public_ip_address = true

  tags = {
    Name         = "console-instance"
    service_type = "console"
    environment  = var.env
  }

  user_data = templatefile("${path.cwd}/user_data.sh.tpl", {
    ecs_cluster_name = var.ecs_cluster_name,
    service_type     = "console"
  })
}

resource "aws_instance" "connector_instance" {
  count                       = var.is_primary_cluster ? 1 : 0
  ami                         = var.ec2_ami
  instance_type               = var.standard_instance_type
  key_name                    = var.keypair_name
  subnet_id                   = var.subnet_ids[0]
  security_groups             = [var.security_group_id]
  iam_instance_profile        = var.ec2_iam_profile
  associate_public_ip_address = true

  tags = {
    Name         = "connector-instance"
    service-type = "connector"
    environment  = var.env
  }

  user_data = templatefile("${path.cwd}/user_data.sh.tpl", {
    ecs_cluster_name = var.ecs_cluster_name,
    service_type     = "connector"
  })
}

resource "aws_instance" "gateway_instance" {
  ami                         = var.ec2_ami
  instance_type               = var.standard_instance_type
  key_name                    = var.keypair_name
  subnet_id                   = var.subnet_ids[0]
  security_groups             = [var.security_group_id]
  iam_instance_profile        = var.ec2_iam_profile
  associate_public_ip_address = true

  tags = {
    Name         = "gateway-instance"
    service-type = "gateway"
    environment  = var.env
  }


  user_data = templatefile("${path.cwd}/user_data.sh.tpl", {
    ecs_cluster_name = var.ecs_cluster_name,
    service_type     = "gateway"
  })
}

resource "aws_launch_template" "media_ec2" {
  name_prefix   = "meida-ec2-"
  image_id      = var.ec2_ami
  instance_type = var.media_instance_type
  key_name      = var.keypair_name
  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = var.subnet_ids[0]
    security_groups             = [var.security_group_id]
  }

  iam_instance_profile {
    name = var.ec2_iam_profile
  }

  tags = {
    service-type = "media"
  }

  user_data = base64encode(templatefile("${path.cwd}/user_data.sh.tpl", {
    ecs_cluster_name = var.ecs_cluster_name,
    service_type     = "media"
  }))
}

resource "aws_autoscaling_group" "media_ec2_autoscale_group" {
  name_prefix         = "meida-ec2-"
  vpc_zone_identifier = var.subnet_ids
  max_size            = 3
  min_size            = 1
  desired_capacity    = 1

  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = true

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  instance_refresh {
    strategy = "Rolling"
  }


  launch_template {
    id      = aws_launch_template.media_ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "8xff-media-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}
