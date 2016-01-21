variable "subnet_size" {
  description = "Size of subnet"
  default = 1
}
variable "gateway_id" {
  description = "Gateway ID to reach internet on Openstack"
}

resource "openstack_networking_network_v2" "main" {
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "main" {
  count = "${var.subnet_size}"
  network_id = "${openstack_networking_network_v2.main.id}"
  cidr = "10.0.${count.index + 1}.0/24"
  ip_version = 4
}

resource "openstack_networking_router_v2" "main" {
  admin_state_up = true
  external_gateway = "${var.gateway_id}"
}

resource "openstack_networking_router_interface_v2" "main" {
  count = "${var.subnet_size}"
  router_id = "${openstack_networking_router_v2.main.id}"
  subnet_id = "${element(openstack_networking_subnet_v2.main.*.id,count.index)}"
}

resource "openstack_compute_secgroup_v2" "shared_security_group" {
  name = "SharedSecurityGroup"
  description = "Shared security group over all instances in platform/optional pattern"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 8501
    to_port = 8501
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 8300
    to_port = 8302
    ip_protocol = "tcp"
    cidr = "10.0.0.0/16"
  }
  rule {
    from_port = 8500
    to_port = 8500
    ip_protocol = "tcp"
    cidr = "10.0.0.0/16"
  }
}

output "subnet_ids" {
  value = "${join(", ", openstack_networking_subnet_v2.main.*.id)}"
}

output "shared_security_group" {
  value = "${openstack_compute_secgroup_v2.shared_security_group.id}"
}
