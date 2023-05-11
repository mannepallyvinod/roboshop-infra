data "aws_ssm_parameter" "ssh_pass" {
  name = "${var.env}.ssh.pass"
}


data "aws_ami" "ami" {
  most_recent = true
  name_regex  = "Ansible-AMI"
  owners      = ["self"]
}
