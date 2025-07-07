resource "aws_key_pair" "openvpn" {
  key_name   = "openvpn"
  public_key = file("C:\\Users\\gnane\\devops\\openvpn.pub")
}


resource "aws_instance" "vpn" {
  ami           = local.ami_id
  instance_type = "t3.micro"

  vpc_security_group_ids = [local.vpn_sg_id]
  subnet_id              = local.public_subnet_id
  # key_name = "daws-84s" #make sure this key exists in AWS
  key_name  = aws_key_pair.openvpn.key_name
  user_data = file("openvpn.sh")

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}0-${var.environment}-vpn"
    }
  )
}