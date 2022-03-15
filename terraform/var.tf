variable "access" {
  default = "  "
}
variable "secret" {
  default = "  "
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
  default = [ "22", "80" ]
}
