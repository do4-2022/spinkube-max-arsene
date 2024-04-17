resource "openstack_compute_secgroup_v2" "spinkube_secgroup" {
  name        = "spinkube_secgroup"
  description = "Spinkube security group"
//ssh
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
// http
  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

}