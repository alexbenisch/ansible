terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.0"
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

resource "hcloud_network" "private" {
  name     = "ansible-net"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "private" {
  network_id   = hcloud_network.private.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_firewall" "web" {
  name = "firewall-web"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_firewall" "db" {
  name = "firewall-db"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "5432"
    source_ips = ["10.0.1.0/24"]
  }
}

resource "hcloud_server" "webservers" {
  count       = var.webserver_count
  name        = "web${format("%02d", count.index + 1)}"
  server_type = var.server_type
  image       = var.image
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.web.id]

  network {
    network_id = hcloud_network.private.id
    ip         = "10.0.1.${count.index + 10}"
  }

  labels = {
    role = "webserver"
    env  = var.environment
  }

  depends_on = [hcloud_network_subnet.private]
}

resource "hcloud_server" "dbserver" {
  name        = "db01"
  server_type = var.db_server_type
  image       = var.image
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.db.id]

  network {
    network_id = hcloud_network.private.id
    ip         = "10.0.1.20"
  }

  labels = {
    role = "dbserver"
    env  = var.environment
  }

  depends_on = [hcloud_network_subnet.private]
}
