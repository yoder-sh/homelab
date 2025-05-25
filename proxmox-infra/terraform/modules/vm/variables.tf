variable "hostname" {
  type = string
}
variable "description" {
}
variable "os" {
  type = string
}
variable "size" {
  default = "small"
}
variable "ip_address" {
  type    = string
  default = null
}
variable "tags" {
  type = string
}
variable "userdata" {
  type = string
}
variable "iso" {
  type    = string
  default = null
}
variable "boot_order" {
  type    = string
  default = "order=virtio0"
}