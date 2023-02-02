# IBM Confidential
# OCO Source Materials
# CLD-119483-1646939470
# (c) Copyright IBM Corp. 2023
# The source code for this program is not published or otherwise
# divested of its trade secrets, irrespective of what has been
# deposited with the U.S. Copyright Office.

packer {
  required_plugins {
    ibmcloud = {
      version = ">=v3.0.1"
      source  = "github.com/IBM/ibmcloud"
    }
    ansible = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "ibm_api_key" {
  type    = string
  default = "${env("IBMCLOUD_API_KEY")}"
}
variable "region" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "resource_group_id" {
  type = string
}

variable "vsi_base_image_name" {
  type = string
}

variable "vsi_user_data_file" {
  type = string
}

variable "vsi_profile" {
  type = string
}

variable "ansible_file" {
  type = string
}

variable "image_name" {
  type = string
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "ibmcloud-vpc" "ubuntu" {
  api_key = "${var.ibm_api_key}"
  region  = var.region

  subnet_id         = var.subnet_id
  resource_group_id = var.resource_group_id

  vsi_base_image_name = var.vsi_base_image_name
  vsi_profile         = var.vsi_profile
  vsi_interface       = "public"
  vsi_user_data_file  = var.vsi_user_data_file

  image_name = var.image_name

  communicator = "ssh"
  ssh_username = "ubuntu"
  ssh_port     = 22
  ssh_timeout  = "15m"

  timeout = "30m"
}

build {
  sources = [
    "source.ibmcloud-vpc.ubuntu"
  ]

  // provisioner "ansible" {
  //   playbook_file = "./ansible/dummy.yml"
  //   user = "ubuntu"
  //   ansible_env_vars = [
  //     "ANSIBLE_SSH_ARGS='-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa'",
  //     "ANSIBLE_HOST_KEY_CHECKING=False"
  //   ]
  // }
}
