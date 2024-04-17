resource "openstack_compute_instance_v2" "instance" {
    name          = "k3s-spinkube"
    image_id    = "dadfa4df-f30e-4578-9104-0801ebbeca9f"
    flavor_name   = "m1.large"
    key_pair      = "spinkube-keypair"
    security_groups = ["spinkube_secgroup"]
    network {
        name = "main"
    }
}