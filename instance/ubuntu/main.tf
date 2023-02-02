# IBM Confidential
# OCO Source Materials
# CLD-119483-1646939466
# (c) Copyright IBM Corp. 2023
# The source code for this program is not published or otherwise
# divested of its trade secrets, irrespective of what has been
# deposited with the U.S. Copyright Office.

provider "ibm" {
  region = var.region
}

data "ibm_is_zones" "this" {
  region = var.region
}

data "ibm_resource_group" "this" {
  name = var.ibm_resource_group
}

resource "random_id" "this" {
  byte_length = 2
}

resource "ibm_is_ssh_key" "public" {
  name       = "bamazeen-ssh-public-key-${random_id.this.hex}"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "ibm_is_vpc" "this" {
  name           = "bamazaeen-vpc-${random_id.this.hex}"
  resource_group = data.ibm_resource_group.this.id
}

resource "ibm_is_subnet" "this" {
  name                     = "bamazeen-subnet-${random_id.this.hex}"
  zone                     = data.ibm_is_zones.this.zones[0]
  vpc                      = ibm_is_vpc.this.id
  total_ipv4_address_count = var.total_ipv4_address_count
}

#########1#########2#########3#########4#########5#########6#########7#########8
# SG Rules
#########1#########2#########3#########4#########5#########6#########7#########8

resource "ibm_is_security_group_rule" "icmp" {
  group     = ibm_is_vpc.this.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  icmp {
    code = 0
    type = 8
  }
}

resource "ibm_is_security_group_rule" "http" {
  group     = ibm_is_vpc.this.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "ssh" {
  group     = ibm_is_vpc.this.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-22-04-1-minimal-amd64-3"
}

resource "null_resource" "run_packer" {
  provisioner "local-exec" {
    command = "ansible-galaxy install geerlingguy.docker"
  }
  provisioner "local-exec" {
    command = "packer version"
  }
  provisioner "local-exec" {
    command = "packer init ./ubuntu.pkr.hcl"
  }
  provisioner "local-exec" {
    command = "packer build -var region=${var.region} -var vsi_user_data_file=./shell/user_data.sh -var subnet_id=${ibm_is_subnet.this.id} -var resource_group_id=${data.ibm_resource_group.this.id} -var vsi_base_image_name=${data.ibm_is_image.ubuntu.name} -var vsi_profile=${var.profile} -var ansible_file=./ansible/playbook.yml -var image_name=bamazeen-image-${random_id.this.hex} -force ./ubuntu.pkr.hcl"
  }
}

data "ibm_is_image" "bamazeen_ubuntu_image" {
  depends_on = [
    null_resource.run_packer
  ]
  name = "bamazeen-image-${random_id.this.hex}"
}

resource "ibm_is_instance" "bamazeen_ubuntu_instance" {
  depends_on = [ibm_is_security_group_rule.ssh]

  name    = "bamazeen-instance-ubuntu-${random_id.this.hex}"
  vpc     = ibm_is_vpc.this.id
  zone    = data.ibm_is_zones.this.zones[0]
  keys    = [ibm_is_ssh_key.public.id]
  image   = data.ibm_is_image.bamazeen_ubuntu_image.id
  profile = var.profile

  primary_network_interface {
    subnet = ibm_is_subnet.this.id
  }
}

resource "ibm_is_floating_ip" "bamazeen_floating_ip" {
  name   = "bamazeen-floating-ip-${random_id.this.hex}"
  target = ibm_is_instance.bamazeen_ubuntu_instance.primary_network_interface[0].id
}

resource "null_resource" "ssh_one_from_the_image" {
  triggers = {
    fip_instance_id = ibm_is_instance.bamazeen_ubuntu_instance.id
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = ibm_is_floating_ip.bamazeen_floating_ip.address
    private_key = file("~/.ssh/id_rsa")
    timeout     = "10m"
  }
  provisioner "remote-exec" {
    inline = [
      "echo $(uname -a)"
    ]
  }
}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "touch ansible/hosts"
  }
  provisioner "local-exec" {
    command = "echo ${ibm_is_floating_ip.bamazeen_floating_ip.address} > ansible/hosts"
  }
  # provisioner "local-exec" {
  #   command = "ansible-playbook ansible/playbook.yml -u ubuntu --become -i ansible/hosts"
  # }
}
