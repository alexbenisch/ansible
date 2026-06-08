terraform {
  required_providers {
    hetznercloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49"
    }
  }
}

provider "hcloud" {
  # reads HCLOUD_TOKEN from environment automatically
}

resource "hcloud_ssh_key" "default" {
  name       = "ansible-key"
  public_key = file(var.ssh_public_key_path)
}

resource "hcloud_server" "webservers" {
  count       = var.webserver_count
  name        = "web${format("%02d", count.index + 1)}"
  server_type = var.server_type
  image       = var.image
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]

  labels = {
    role = "webserver"
    env  = var.environment
  }
}

resource "hcloud_server" "dbserver" {
  name        = "db01"
  server_type = var.db_server_type
  image       = var.image
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]

  labels = {
    role = "dbserver"
    env  = var.environment
  }
}
