# =============================================================================
# Variables
# =============================================================================

variable "hcloud_token" {
  description = "Hetzner API token"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name of the server (must be unique in your Hetzner project)"
  type        = string
}

variable "server_type" {
  description = "Hetzner server type (e.g., cpx21, cpx41, cax41)"
  type        = string
  default     = "cpx41"
}

variable "location" {
  description = "Hetzner datacenter location (e.g., fsn1, nbg1, hel1)"
  type        = string
  default     = "fsn1"
}

variable "image" {
  description = "OS image to use (slug or ID)"
  type        = string
  default     = "ubuntu-22.04"
}

variable "ssh_keys" {
  description = "List of SSH key names or IDs to attach"
  type        = list(string)
  default     = []
}

variable "hetzner_ssh_key_name" {
  description = "Name of a single SSH key in Hetzner (alternative to ssh_keys)"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key content to inject at boot"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels to apply to the server"
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}