output "webserver_ips" {
  description = "Public IPs of webservers"
  value       = hcloud_server.webservers[*].ipv4_address
}

output "dbserver_ip" {
  description = "Public IP of dbserver"
  value       = hcloud_server.dbserver.ipv4_address
}

output "ansible_inventory" {
  description = "Generated Ansible inventory"
  value = templatefile("${path.module}/inventory.tpl", {
    webservers = hcloud_server.webservers[*].ipv4_address
    dbserver   = hcloud_server.dbserver.ipv4_address
  })
}
