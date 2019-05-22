resource "openstack_compute_instance_v2" "nfs-server" {
  name            = "job-working-dir.internal.galaxyproject.eu"
  image_id        = "vggp-v31-j122-1a432e1e6448-master"
  flavor_name     = "m1.large"
  key_pair        = "cloud2"
  security_groups = ["public"]

  network {
    name = "bioinf"
  }

  block_device {
    uuid                  = "${openstack_blockstorage_volume_v2.volume_nfs_data.id}"
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = -1
    delete_on_termination = true
  }
}

resource "aws_route53_record" "nfs-server" {
  zone_id = "${var.zone_usegalaxy_eu}"
  name    = "job-working-dir.internal.galaxyproject.eu"
  type    = "A"
  ttl     = "3600"
  records = ["${openstack_compute_instance_v2.nfs-server.access_ip_v4}"]
}

resource "openstack_blockstorage_volume_v2" "nfs-server" {
  name        = "job-working-dir"
  description = "Data volume for job-working-dir"
  size        = "${1024 * 20}"
}

resource "openstack_compute_volume_attach_v2" "nfs-data-va" {
  instance_id = "${openstack_compute_instance_v2.nfs-server.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.nfs-server.id}"
}
