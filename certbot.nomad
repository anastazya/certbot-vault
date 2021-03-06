job "certbot" {
  region = "uk"
  type = "batch"
  datacenters = ["dc1"]
  parameterized {
    payload       = "forbidden"
    meta_required = ["domain", "email"]
  }

  group "batch" {
    count = 1
    task "certonly" {
      env {
        CONSUL_HTTP_ADDR = "http://${attr.unique.network.ip-address}:8500"
        NOMAD_ADDR = "http://${attr.unique.network.ip-address}:8500"
        VAULT_ADDR = "https://vault.stn.corrarello.net"
        VAULT_SKIP_VERIFY = "true"
      }
      vault {
        policies = ["letsencrypt"]

        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }
      driver = "docker"
      config {
        image = "ncorrare/certbot-he-vault:release-0.0.11"
        args = ["-d ${NOMAD_META_domain}", "-m ${NOMAD_META_email}"]
      }
      resources {
        cpu = 100 # Mhz
        memory = 128 # MB
        network {
          mbits = 10
        }
      }
    }
  }
}
