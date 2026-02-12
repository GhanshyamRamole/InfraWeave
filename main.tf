# --- VPC & Networking ---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "dev-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.az
  tags                    = { Name = "dev-public-subnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "dev-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "dev-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# --- Security Group (Using dynamic blocks for cleaner code) ---
resource "aws_security_group" "web_sg" {
  name   = "allow-web-traffic"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = [22, 80, 81, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Node Servers (Using Count for scalability) ---
resource "aws_instance" "nodes" {
  count                  = 3
  ami                    = var.AWS_AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public.id
  key_name               = var.key
  user_data              = file("${path.module}/nodes.sh")

  tags = {
    Name = "node${count.index + 1}"
  }
}

# --- Ansible Control Plane ---
resource "aws_instance" "ansible" {
  ami                    = var.AWS_AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public.id
  key_name               = var.key
  user_data              = file("${path.module}/ansible.sh")

  connection {
    type        = "ssh"
    user        = "ec2-user" 
    password      = var.passwd
    host        = self.public_ip
    timeout     = "2m"
  }
  

  # migrate Ansible files to Ansible Master 
  provisioner "file" {
    source      = "${path.module}/playbook.yml" 
    destination = "/tmp/playbook.yml"    
  }

  provisioner "remote-exec" {
    inline = concat(
      # Update /etc/hosts for all worker-nodes
      [for node in aws_instance.nodes : "echo '${node.private_ip} ${node.tags["Name"]}' | sudo tee -a /etc/hosts"],
      
      [
        # Wait until the user and directory are created by ansible.sh
        "echo 'Waiting for bootstrap script to create itadmin and directory...'",
        "timeout 300s bash -c 'while ! [ -d /home/itadmin/punepro ]; do sleep 10; done'",
        
        # Now move the file and set permissions
        "sudo mv /tmp/playbook.yml /home/itadmin/punepro/playbook.yml",
        "sudo chown -R itadmin:itadmin /home/itadmin/punepro/",
        
        # Execute the playbook as the itadmin user
        "cd /home/itadmin/punepro/ && sudo -u itadmin ansible-playbook playbook.yml"
      ]
    )
  }


  tags = { Name = "ansible-server" }
}
