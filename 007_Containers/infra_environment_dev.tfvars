config = {
  environment_longname                   = "dev"
  regulation_longname                    = "nonprod"
  regulation_shortname                   = "np"
  location_longname                      = "uksouth"
  location_shortname                     = "uks"
  dns_service_ip                         = "10.255.255.10" # IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns).
  docker_bridge_cidr                     = "172.29.0.0/16"
  service_cidr                           = "10.255.254.0/23" # A list of CIDRs to use for Kubernetes services. For single-stack networking a single IPv4 CIDR is expected. For dual-stack networking an IPv4 and IPv6 CIDR are expected. 
  kubernetes_version                     = "1.30.6"
  default_node_pool_orchestrator_version = "1.30.6"
}
