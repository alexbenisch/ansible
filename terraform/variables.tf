variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "environment" {
  description = "Deployment environment (production, staging)"
  type        = string
  default     = "production"
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1" # Nuremberg
}

variable "image" {
  description = "Server OS image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "server_type" {
  description = "Hetzner server type for webservers"
  type        = string
  default     = "cx23"
}

variable "db_server_type" {
  description = "Hetzner server type for dbserver"
  type        = string
  default     = "cx33"
}

variable "webserver_count" {
  description = "Number of webserver instances"
  type        = number
  default     = 2
}
