# IBM Confidential
# OCO Source Materials
# CLD-119483-1646939467
# (c) Copyright IBM Corp. 2023
# The source code for this program is not published or otherwise
# divested of its trade secrets, irrespective of what has been
# deposited with the U.S. Copyright Office.

output "baked_image" {
  value = data.ibm_is_image.bamazeen_ubuntu_image
}

output "baked_image_id" {
  value = data.ibm_is_image.bamazeen_ubuntu_image.id
}

output "floating_ip" {
  value = ibm_is_floating_ip.bamazeen_floating_ip.address
}
