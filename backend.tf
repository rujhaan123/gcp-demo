terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Rujhaan-Resource"

    workspaces {
      name = "gcp-rg-deploy"
    }
  }
}
