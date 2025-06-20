# Example minimal Boundary config (controller+worker on same host)

disable_mlock = true

controller {
  name = "controller-1"
  description = "Local controller"
  database {
    url = "file:///var/lib/boundary/controller.db"
  }
  api_listen_address = "0.0.0.0:9200"
  cluster_listen_address = "0.0.0.0:9201"
}

worker {
  name = "worker-1"
  description = "Local worker"
  controllers = [ "127.0.0.1:9201" ]
  public_addr = "127.0.0.1"
}

listener "tcp" {
  purpose = "api"
  address = "0.0.0.0"
  port = 9200
  tls_disable = true
}