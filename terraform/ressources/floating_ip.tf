resource "openstack_networking_floatingip_v2" "floatip" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "associate_floatip" {
    floating_ip = openstack_networking_floatingip_v2.floatip.address
    instance_id = openstack_compute_instance_v2.instance.id
}