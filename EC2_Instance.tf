provider "aws" {
  region     = "ap-south-1"
  profile    = "task"
}

resource "aws_key_pair" "key" {
key_name = "mykeyy"
public_key="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAhK0cicdp9YTALTfTQbx9DqjDj/1ses0qQzUkziwMnvogGkQ+TcIxSdkebbCAUFokewdmjjVoDQocCSUZhy1ybmusPKqQe7L94XkwIVH87arDeUKon2wOqQ1QKEDZaxNSKFeiSam9d6WgI5CBG2AhFmSwYMsYXifnPF6JeGexXEvAdus0j3vMdDElxJUgatgW6Z66otd0eGOMrOCE5YK6P8AxrPu3EKxeHPOBH8ullXQsQEcPLOT2JoPDLpSNiGG3hBP3MBt9rM/ITAk2PvYOJouQbZUE1YivXgBlieFDr7fxxVBD1+5hNtUnw/vOpRuAygNB46u+siG4A9Pf/swOew== rsa-key-20200612"
}

resource "aws_security_group" "add_rules" {
  name        = "add_rules"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "vpc-00968b68"

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp" 
    cidr_blocks=["0.0.0.0/0"]
  }
ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp" 
    cidr_blocks=["0.0.0.0/0"]
  }
egress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp" 
    cidr_blocks=["0.0.0.0/0"]
  }
egress {
    description = "HTTP from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp" 
    cidr_blocks=["0.0.0.0/0"]
  }


  tags = {
    Name = "add_rules"
  }
}




resource "aws_ebs_volume" "ebsv" {
  availability_zone = aws_instance.inst.availability_zone
  size              = 1

  tags = {
    Name = "myebsv"
  }
}



resource "aws_volume_attachment" "v_att" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.ebsv.id
  instance_id = aws_instance.inst.id
  force_detach = true

}

resource "aws_instance" "inst" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "mykeyy"
  security_groups = ["add_rules"]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/USER/Desktop/terra1/mykeyY.pem")
    host     = aws_instance.inst.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "task1os"
  }

}

resource "null_resource" "local1"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.inst.public_ip} > publicip.txt"
  	}
}




resource "null_resource" "remote2"  {

depends_on = [
    aws_volume_attachment.v_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/USER/Desktop/terra1/mykeyy.pem")
     host     = aws_instance.inst.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdd",
      "sudo mount  /dev/xvdd  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/ridham-ux/hybrid1.git /var/www/html/"
    ]
  }
}






