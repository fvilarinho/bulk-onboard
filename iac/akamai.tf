# Definition of the Akamai EdgeGrid credentials.
provider "akamai" {
  config {
    host          = var.edgeGridHost
    access_token  = var.edgeGridAccessToken
    client_token  = var.edgeGridClientToken
    client_secret = var.edgeGridClientSecret
  }
}