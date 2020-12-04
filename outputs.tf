output "vpc-VPC-ID" {
    value = aws_vpc.pavm-vpc.id
}

output "subnet-Management-Subnet-ID" {
    value = aws_subnet.mgmt-subnet.id
}

output "vpc-Default-Security-Group-ID" {
    value = aws_security_group.default-security-gp.id
}

output "general-Instance-ID" {
    value = aws_instance.pavm.id
}

output "ip-Management-Public-IP" {
    value = aws_instance.pavm.public_ip
}

output "ip-Management-Private-IP" {
    value = aws_instance.pavm.private_ip
}

output "ip-Untrust-Public-IP" {
    value = aws_eip.untrust_eip.public_ip
}

output "ip-Untrust-Private-IP" {
    value = aws_eip.untrust_eip.private_ip
}

output "ip-Trust-Private-IP" {
    value = aws_network_interface.trust_eni.private_ips
}
