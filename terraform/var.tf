variable "access" {
  default = "AKIA2CR7DPBBHJT3XCFJ"
}
variable "secret" {
  default = "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"
}
variable "region" {
  default = "ap-south-1"
}
variable "cidr" {
  default = "172.26.0.0/16"
}
variable "project" {
  default = "TeraAns"
}
variable "AZ" {
  type = list
  default = [ "ap-south-1a", "ap-south-1b" ]
}
variable "port" {
  type = list
  default = [ "22", "80", "443" ]
}
