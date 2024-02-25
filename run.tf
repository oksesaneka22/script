provider "aws" {
  region = "eu-north-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
resource "aws_iam_user" "my_user" {
  name = "my_user"
}
resource "aws_iam_group_membership" "my_membership" {
  name = "sasha_membership"
  users = [ aws_iam_user.my_user.name ]
  group = aws_iam_group.my_group.name
}
resource "aws_iam_group" "my_group" {
  name = "my_group"
}
resource "aws_iam_policy" "my_group_policy" {
  name = "my_group_policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ec2scheduled.amazonaws.com",
                        "elasticloadbalancing.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com",
                        "transitgateway.amazonaws.com"
                    ]
                }
            }
        }
    ]
})
}
resource "aws_iam_access_key" "keysss" {
  user = aws_iam_user.my_user.name
}
resource "aws_iam_group_policy_attachment" "my_attach" {
  group = aws_iam_group.my_group.name
  policy_arn = aws_iam_policy.my_group_policy.arn
}

provider "aws" {
  alias   = "my_user"
  region  = "eu-north-1"
  access_key = aws_iam_access_key.keysss.id
  secret_key = aws_iam_access_key.keysss.secret
}


resource "aws_instance" "nmd221" {
 provider = aws.my_user
 availability_zone = "eu-north-1a"
 ami = "ami-0014ce3e52359afbd"
 instance_type = "t3.micro"
 key_name = "ubuntu"
 ebs_block_device {
   device_name = "/dev/sda1"
   volume_size = 8
   volume_type = "standard"
 }
 tags = {
    Name = "UBUNTU_SERVER_22.04_beta_ultra_betatest_only_for_admins_ULtraserver_250fps_1tb_memory"
  }
  
}
