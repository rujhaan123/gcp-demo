provider "google" {
  credentials = var.GOOGLE_CREDENTIALS
  project     = var.project
  region      = var.region
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-mode-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "firewall" {
  name    = "new-firewall-externalssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22","443"]
  }

  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["externalssh"]
}

resource "google_compute_address" "static" {
  name       = "vm-public-address"
  project    = var.project
  region     = var.region
  depends_on = [google_compute_firewall.firewall]
}

resource "google_compute_instance" "default" {
  name         = "terraform-instance"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "centos-7-v20200403"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.default.name

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    ssh-keys = "user:${var.public_key}"
  }
}


# google_client_config and kubernetes provider must be explicitly specified like the following.
/* data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project
  name                       = "gke-test-1-tfe"
  region                     = "us-west1"
  zones                      = ["us-west1-a"]
  network                    = "default"
  subnetwork                 = "default"
  ip_range_pods              = "gke-pods-range"
  ip_range_services          = "ip-range-services"
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = true

  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-medium"
      node_locations            = "us-west1-b,us-west1-a"
      min_count                 = 2
      max_count                 = 4
      local_ssd_count           = 0
      spot                      = false
      disk_size_gb              = 40
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      enable_gvnic              = false
      logging_variant           = "DEFAULT"
      auto_repair               = true
      auto_upgrade              = true
      service_account           = "tfe-test-account@triple-silo-412717.iam.gserviceaccount.com"
      preemptible               = false
      initial_node_count        = 2
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
} */
