ui = true

storage "consul" {
  address = "vault-db:8500"
  scheme  = "http"
  path    = "vault"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}