resource "openstack_compute_keypair_v2" "spinkube-keypair" {
  name       = "spinkube-keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}