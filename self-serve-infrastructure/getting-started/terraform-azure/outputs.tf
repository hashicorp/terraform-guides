output "linux_vm_public_name"{
  value = "${module.linuxservers.public_ip_dns_name}"
}
