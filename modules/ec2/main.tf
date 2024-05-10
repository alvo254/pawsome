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

resource "aws_instance" "bastion_host" {
  ami = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
    
  subnet_id = var.public_subnet
  key_name = "${aws_key_pair.pawsome_key.key_name}"
  vpc_security_group_ids = [var.security_group]

  provisioner "file" {
    source      = "${path.module}/private_key"
    destination = "/home/ec2-user/.ssh/authorized_keys"
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for SSH to become available...'",
      "mkdir -p /home/ec2-user/.ssh",
      "cat /home/ec2-user/private_key >> /home/ec2-user/.ssh/authorized_keys",
      "chmod 600 /home/ec2-user/.ssh/authorized_keys",
      "rm /home/ec2-user/private_key"  # Optional: Remove the private key after copying
    ]
  }

  connection {
    type                = "ssh"
    user                = "ec2-user"
    private_key         = file("${path.module}/private_key")
    host                = self.private_ip
    bastion_host        = aws_instance.bastion_host.public_ip
    bastion_user        = "ec2-user"
    bastion_private_key = file("${path.root}./pawsome/paw-key.pem")
  }

  tags = {
    Name = "bastion_host"
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


resource "null_resource" "ssh_key_generation" {
  provisioner "local-exec" {
    command = "yes | ssh-keygen -t rsa -b 4096 -f ${path.module}/private_key -N ''"
  }
}
resource "aws_key_pair" "ssh_key" {
  key_name   = "my_ssh_key"
  public_key = file("${path.module}/private_key.pub")
}