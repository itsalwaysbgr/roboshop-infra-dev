module "backend_alb" {
  source                     = "terraform-aws-modules/alb/aws" # this is an open source module from git 
  version                    = "9.17.0"
  internal                   = true # private load balancer
  enable_deletion_protection = false


  name                  = "${var.project}-${var.environment}-backend-alb" #roboshop dev backend alb
  vpc_id                = local.vpc_id
  subnets               = local.private_subnet_ids
  create_security_group = false
  security_groups       = [local.backend_alb_sg_id]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-backend_alb"
    }
  )
}



# amazon_resource_name(arn)

resource "aws_lb_listener" "backend_alb" {
  load_balancer_arn = module.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1> yo, bro this is backend alb </h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "backend_alb" {
  zone_id = var.zone_id
  name    = "*.backend-dev.${var.zone_name}"
  type    = "A"

  alias {
    name                   = module.backend_alb.dns_name
    zone_id                = module.backend_alb.zone_id # this is the zone_id of alb and not our zone_id
    evaluate_target_health = true
  }
}