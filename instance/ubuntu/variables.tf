# IBM Confidential
# OCO Source Materials
# CLD-119483-1646939471
# (c) Copyright IBM Corp. 2023
# The source code for this program is not published or otherwise
# divested of its trade secrets, irrespective of what has been
# deposited with the U.S. Copyright Office.

variable "region" {
  default = "us-east"
  description = "Region name"
  type        = string
}

variable "prefix" {
  default     = "prefix"
  type        = string
  description = "The prefix string"
}

variable "ibm_resource_group" {
  default     = "Default"
  type        = string
  description = "IBM Cloud resource group name"
}
variable "total_ipv4_address_count" {
  description = "IBM total address count"
  type        = number
  default     = 256
}

variable "profile" {
  default = "cx2-2x4"
  type    = string
}
