# --- Ansible Server Outputs ---
output "ansible_public_ip" {
  description = "Public IP address of the Ansible Control Node"
  value       = aws_instance.ansible.public_ip
}

output "ansible_private_ip" {
  description = "Private IP address of the Ansible Control Node"
  value       = aws_instance.ansible.private_ip
}

# --- Node Cluster Outputs (Dynamic) ---
output "node_public_ips" {
  description = "List of Public IPs for all managed nodes"
  value       = aws_instance.nodes[*].public_ip
}

output "node_private_ips" {
  description = "List of Private IPs for all managed nodes"
  value       = aws_instance.nodes[*].private_ip
}

# --- Bonus: Comprehensive Map ---
output "node_summary" {
  description = "A map of node names to their IP addresses"
  value = {
    for instance in aws_instance.nodes :
    instance.tags["Name"] => {
      public  = instance.public_ip
      private = instance.private_ip
    }
  }
}
