## This outputs the starting keys/info for the scenario 

output "cloudgoat_output_target_ec2_server_ip" {
  value = aws_instance.ssrf_server.public_ip
}
