data "external" "delay" {
  program = ["./modules/openshift/delay-aws"]

  depends_on = ["aws_instance.master", "aws_instance.node1"]
}

data "template_file" "inventory" {
  template = "${file("${path.module}/files/install-from-bastion.sh")}"

  vars {
    wait = "${data.external.delay.result["wait"]}"
    master_ip = "${aws_instance.master.public_ip}"
    private_key = "${var.private_key_data}"
  }
}

resource "local_file" "inventory" {
  content = "${data.template_file.inventory.rendered}"
  filename = "${path.module}/files/install-openshift.sh"
}

//  Launch configuration for the bastion.
resource "aws_instance" "bastion" {
  ami                  = "${data.aws_ami.amazonlinux.id}"
  instance_type        = "t2.micro"
  subnet_id            = "${aws_subnet.public-subnet.id}"

  vpc_security_group_ids = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-ssh.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  key_name = "${var.key_name}"

  tags {
    Name    = "${var.name_tag_prefix} Bastion"
    Project = "openshift"
    owner = "${var.owner}"
    TTL = "${var.ttl}"
  }

  provisioner "remote-exec" {
    script = "${local_file.inventory.filename}"
    on_failure = "continue"
    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${var.private_key_data}"
    }
  }
}
