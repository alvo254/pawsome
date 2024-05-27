resource "aws_instance" "pawsome" {
  ami = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.ssh_key.key_name }"
  
  
  subnet_id = var.private_subent1

  user_data = data.template_file.user_data.rendered
  vpc_security_group_ids = [var.bastion_host_sg]
  tags = {
      Name = "pawsome"
  }
}

# References in depends_on must be to a whole object (resource, etc), not to an attribute of an object.
resource "aws_instance" "bastion_host" {
  ami = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
    
  subnet_id = var.public_subnet
  key_name = "${aws_key_pair.pawsome_key.key_name}"
  vpc_security_group_ids = [var.security_group]




  tags = {
    Name = "bastion_host"
  }
  
}

resource "aws_instance" "pass_through" {
  ami = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
    
  subnet_id = var.public_subnet
  key_name = "${aws_key_pair.pawsome_key.key_name}"
  vpc_security_group_ids = [var.security_group]

  # provisioner "file" {
  #   source      = "${path.module}/private_key.pub"
  #   destination = "/home/ec2-user/.ssh/authorized_keys"
  # }

    provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for SSH to become available...'",
      "mkdir -p /home/ubuntu/.ssh",
      "cat /home/ubuntu/private_key >> /home/ubuntu/.ssh/authorized_keys",
      "chmod 600 /home/ubuntu/.ssh/authorized_keys",
      "rm /home/ubuntu/private_key"  # Optional: Remove the private key after copying
    ]

  }

  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = file("${path.module}/private_key")
    host                = self.private_ip
    bastion_host        = aws_instance.bastion_host.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("${path.module}/../../paw-key.pem")

  }

  tags = {
    Name = "pass_through"
  }
}


resource "aws_key_pair" "pawsome_key" {
  key_name = "pawsome-key"
  //storing ssh key on the server
  public_key = tls_private_key.RSA.public_key_openssh
}


resource "tls_private_key" "RSA" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "paw-ssh-keys" {
	# content = tls_private_key.RSA.private_key_pem
	content = tls_private_key.RSA.private_key_pem
	filename = "paw-key.pem"
}


data "template_file" "user_data" {
  template = file("${path.module}/install.sh")
}


# resource "null_resource" "ssh_key_generation" {
#   provisioner "local-exec" {
#     command = "yes | ssh-keygen -t rsa -b 4096 -f ${path.module}/private_key -N ''"
#   }
# }

resource "null_resource" "ssh_key_gen" {
  provisioner "local-exec" {
    command = "scp -i ${path.module}/../../paw-key.pem ${path.module}/private_key.pub ubuntu@${aws_instance.bastion_host.public_ip}:/home/ubuntu/.ssh/authorized_keys"
    # command = "scp -i ${aws_instance.bastion_host.private_key_path} -o StrictHostKeyChecking=no ${path.root}/pawsome/paw-key.pem ec2-user@${aws_instance.bastion_host.public_ip}:/home/ec2-user/.ssh/authorized_keys"
  }
} 

resource "aws_key_pair" "ssh_key" {
  key_name   = "my_ssh_key"
  public_key = file("${path.module}/private_key.pub")
}