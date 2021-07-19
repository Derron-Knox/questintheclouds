variable "profile" {
  type    = string
  default = "default"
}

variable "region-master" {
  type    = string
  default = "us-east-1"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "webserver-port" {
  type    = number
  default = 80
}

variable "mattermost-port" {
  type    = number
  default = 3000
}

variable "quest-instance-type" {
  type    = string
  default = "t2.micro"
}
