resource "aws_instance" "mongodb" {
  ami           = local.ami_id
  instance_type = "t3.micro"

  vpc_security_group_ids = [local.mongodb_sg_id]
  subnet_id              = local.database_subnet_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-mongodb"
    }
  )
}


# we made a condition below by using trigger's 
# like if the instance created then it should run the script -
# in remote server


resource "terraform_data" "mongodb" {
  triggers_replace = [
    aws_instance.mongodb.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.mongodb.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }



  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mongodb ${var.environment}"
    ]
  }
}

resource "aws_instance" "redis" {
  ami           = local.ami_id
  instance_type = "t3.micro"

  vpc_security_group_ids = [local.redis_sg_id]
  subnet_id              = local.database_subnet_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-redis"
    }
  )
}


# we made a condition below by using trigger's 
# like if the instance created then it should run the script -
# in remote server


resource "terraform_data" "redis" {
  triggers_replace = [
    aws_instance.redis.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.redis.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }



  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh redis ${var.environment}"
    ]
  }
}





resource "aws_instance" "mysql" {
  ami           = local.ami_id
  instance_type = "t3.micro"

  vpc_security_group_ids = [local.mysql_sg_id]
  subnet_id              = local.database_subnet_id
  iam_instance_profile   = "EC2RoleToFetchSSMParams"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-mysql"
    }
  )
}


# we made a condition below by using trigger's 
# like if the instance created then it should run the script -
# in remote server


resource "terraform_data" "mysql" {
  triggers_replace = [
    aws_instance.mysql.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.mysql.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }



  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mysql ${var.environment}"
    ]
  }
}




resource "aws_instance" "rabbitmq" {
  ami           = local.ami_id
  instance_type = "t3.micro"

  vpc_security_group_ids = [local.rabbitmq_sg_id]
  subnet_id              = local.database_subnet_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-rabbitmq"
    }
  )
}


# we made a condition below by using trigger's 
# like if the instance created then it should run the script -
# in remote server


resource "terraform_data" "rabbitmq" {
  triggers_replace = [
    aws_instance.rabbitmq.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.rabbitmq.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }



  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh rabbitmq ${var.environment}"
    ]
  }
}

resource "aws_route53_record" "mongodb" {
  zone_id         = var.zone_id
  name            = "mongodb-${var.environment}.${var.zone_name}"
  type            = "A"
  ttl             = 1
  records         = [aws_instance.mongodb.private_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "redis" {
  zone_id         = var.zone_id
  name            = "redis-${var.environment}.${var.zone_name}"
  type            = "A"
  ttl             = 1
  records         = [aws_instance.redis.private_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "mysql" {
  zone_id         = var.zone_id
  name            = "mysql-${var.environment}.${var.zone_name}"
  type            = "A"
  ttl             = 1
  records         = [aws_instance.mysql.private_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "rabbitmq" {
  zone_id         = var.zone_id
  name            = "rabbitmq-${var.environment}.${var.zone_name}"
  type            = "A"
  ttl             = 1
  records         = [aws_instance.rabbitmq.private_ip]
  allow_overwrite = true
}
