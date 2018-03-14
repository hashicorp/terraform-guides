# Need to add actual script inline with HEREDOC - below path doesn't exist
/*
data "template_file" "php-startup-script" {
  template = "${file("${format("%s/../scripts/gceme.sh.tpl", path.module)}")}"
  vars {
    PROXY_PATH = ""
  }
}
*/

module "mig1" {
  source            = "GoogleCloudPlatform/managed-instance-group/google"
  region            = "${var.region}"
  zone              = "${var.zone}"
  name              = "${var.name}"
  size              = 2
  service_port      = "${var.service_port}"
  service_port_name = "http"
  target_pools      = ["${module.gce-lb-fr.target_pool}"]
  target_tags       = ["${var.tags}"]
  startup_script    = "${data.template_file.php-startup-script.rendered}"
}

module "gce-lb-fr" {
  source       = "GoogleCloudPlatform/lb/google"
  region       = "${var.region}"
  name         = "${var.name}"
  service_port = "${var.service_port}"
  target_tags  = ["${var.tags}"]
}
