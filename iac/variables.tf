# Defines the property (CDN) settings filename.
variable "settingsFilename" {
  type    = string
  default = "settings.json"
}

# EdgeGrid API host.
variable "edgeGridHost" {
  type = string
}

# EdgeGrid API access token.
variable "edgeGridAccessToken" {
  type = string
}

# EdgeGrid API client token.
variable "edgeGridClientToken" {
  type = string
}

# EdgeGrid API client secret.
variable "edgeGridClientSecret" {
  type = string
}