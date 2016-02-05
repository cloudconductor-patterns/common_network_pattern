variable "subnet_size" {
  description = "Size of subnet"
  default = 1
}

resource "wakamevdc_network" "main" {
  count = "${var.subnet_size}"
  display_name = "Common Network"
  description = "common network"
  ipv4_network = "10.0.${count.index + 1}.0"
  prefix = 24
  network_mode = "l2overlay"
  dc_network_name = "vnet"
  editable = true

  dhcp_range {
    range_begin = "10.0.${count.index + 1}.10"
    range_end = "10.0.${count.index + 1}.50"
  }
}

resource "wakamevdc_security_group" "shared_security_group" {
  display_name = "SharedSecurityGroup"
  description = "Shared security group over all instances in platform/optional pattern"
  rules = "tcp:22,22,ip4:0.0.0.0\ntcp:8501,8501,ip4:0.0.0.0\ntcp:8500,8500,ip4:10.0.0.0/16\ntcp:8300,8300,ip4:10.0.0.0/16\ntcp:8301,8301,ip4:10.0.0.0/16\ntcp:8302,8302,ip4:10.0.0.0/16"
}

output "subnet_ids" {
  value = "${join(", ", wakamevdc_network.main.*.id)}"
}

output "shared_security_group" {
  value = "${wakamevdc_security_group.shared_security_group.id}"
}
