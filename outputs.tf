# =============================================================================
# Outputs
# =============================================================================

output "server_id" {
  description = "Hetzner server ID"
  value       = hcloud_server.main.id
}

output "server_name" {
  description = "Server name"
  value       = hcloud_server.main.name
}

output "ipv4_address" {
  description = "Public IPv4 address"
  value       = hcloud_server.main.ipv4_address
}

output "ipv6_address" {
  description = "Public IPv6 address"
  value       = hcloud_server.main.ipv6_address
}

output "connection_info" {
  description = "SSH command to connect to the server"
  value       = "ssh -o StrictHostKeyChecking=no root@${hcloud_server.main.ipv4_address}"
}

output "server_status" {
  description = "Current server status"
  value       = hcloud_server.main.status
}