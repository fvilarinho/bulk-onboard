# Definition of the Terraform providers and state management.
terraform {
  # Defines the providers used by the provisioning.
  required_providers {
    akamai = {
      source = "akamai/akamai"
    }
  }
}

# Loads all settings.
locals {
  settings = jsondecode(file(pathexpand(var.settingsFilename)))
}