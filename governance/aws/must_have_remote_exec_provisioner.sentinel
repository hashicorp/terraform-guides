import "tfconfig"

main = rule {
  all tfconfig.resources.aws_instance as _, r {
    any r.provisioners as _, p {
      p.type == "remote-exec"
    }
  }
}
