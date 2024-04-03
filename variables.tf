variable "GOOGLE_CREDENTIALS" {
  description = "The Google Cloud credentials"
  type        = string
}

variable "project" {
  description = "Project where we are actually deploying resources"
  type        = string
}

variable "region" {
  description = "The region where resources should be created"
  type        = string
}

variable "privatekeypath" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "publickeypath" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

