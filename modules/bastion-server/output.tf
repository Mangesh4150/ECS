output "latest_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}
