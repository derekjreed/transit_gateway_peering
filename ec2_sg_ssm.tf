# put ssh-public key here , if you need ssh access

resource "aws_key_pair" "ITKey" {
  key_name   = "kd"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC39GvH0QEEJzMUKK/5h1aspvy1/ieiuS+7KD9ogpirBcuhbVw395roqw96JE5DbpF943FTFoFsn6LtbbjRimm52ABT1VoXxX7ytcN4jAHTkqcxgURDQs3TpM7IDXmd05/rfDfLP8KbuGyALVurGgSxfQ2NC78NoHXgD66qkx3HC3eO4rAszT93ZqyFdySsDZrVGF6sTA/carH+JIWaoswczEReR0MfkHpDT3E7o32kSkFCqHKFfPfzAtcfRP/Ur86pkyNm5oK2SSKilI643flnwr1ZvHk5bwtxuVA4Om94AQ1zsEiSAiVG2gcE88PhLdpdrnB1OCfvzrAD1f7Pm3Txj8fAG8Obz6Sbr9tLgjBLVuni7mLVDCHf79bxoq7SXlXjF1mURoEe3aRfzUfuOepH/0P9/sXB8jWqCMIknXZoiKDTrrwBoL+rB78mnYFlKtRh720EmeOr1pGZjscb01eMO5jP0olFm4SdoeBFiT6QaqKdMoYHmwWwPXIdbohkve8= blah@DESKTOP-INDC8UO"
}

data "template_file" "startup" {
  template = file("webserver-installer.sh")
}

resource "aws_security_group" "allow_web_local" {
  name        = "webserver1"
  vpc_id      = aws_vpc.local.id
  description = "Allows access to Web Port"
  #allow http 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # allow https
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = 3333
    to_port     = 3333
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    lifecycle = "test"
  }
  lifecycle {
    create_before_destroy = true
  }
} #security group ends here

resource "aws_instance" "ec2_local" {
  //ami                    = "ami-0b418580298265d5c"
  ami                    = "ami-0cf10cdf9fcd62d37"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.local1.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_web_local.id]
  iam_instance_profile   = aws_iam_instance_profile.dev-resources-iam-profile.name
  key_name               = aws_key_pair.ITKey.key_name
  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 8
  }
  tags = {
    Name      = "test-ec2-local"
    lifecycle = "test"
  }
  user_data = data.template_file.startup.rendered
}

resource "aws_security_group" "allow_web_remote" {
  name        = "webserver2"
  vpc_id      = aws_vpc.remote.id
  description = "Allows access to Web Port"
  #allow http 
  ingress {
    from_port   = 3333
    to_port     = 3333
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # allow https
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = 3333
    to_port     = 3333
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    lifecycle = "test"
  }
  lifecycle {
    create_before_destroy = true
  }
} #security group ends here

resource "aws_instance" "ec2_remote" {
  //ami                    = "ami-0b418580298265d5c"
  ami                    = "ami-0cf10cdf9fcd62d37"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.remote1.id
  associate_public_ip_address = false
  vpc_security_group_ids = [aws_security_group.allow_web_remote.id]
  iam_instance_profile   = aws_iam_instance_profile.dev-resources-iam-profile.name
  key_name               = aws_key_pair.ITKey.key_name
  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 8
  }
  tags = {
    Name      = "test-ec2-remote"
    lifecycle = "test"
  }
  user_data = data.template_file.startup.rendered
}