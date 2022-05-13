output "exposed_ip" {
  description = "The IP address to visit."
  value       = module.scale-set.exposed_ip
}
