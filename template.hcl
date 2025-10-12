# === Basis ===
datacenter = "dc1"                 
node_name  = "consul-srv-1"        
data_dir   = "__DATA_DIR__"

client_addr = "0.0.0.0"
addresses { http = "0.0.0.0"  https = "0.0.0.0"  dns = "0.0.0.0" }
ports     { http = 8500  https = 8501 } 

server           = true
bootstrap_expect = 3

bind_addr  = "192.168.178.40"            
retry_join = ["192.168.178.40","192.168.178.51","192.168.178.48"]  

ui_config { enabled = true }

# === Logging ===
log_level = "DEBUG"
log_file  = "__LOG_FILE__"
log_rotate_duration  = "24h"
log_rotate_bytes     = 104857600
log_rotate_max_files = 7  

# === Gossip (Serf LAN) ===
encrypt                 = "__GOSSIP_KEY__"
encrypt_verify_incoming = false   
encrypt_verify_outgoing = false

# === TLS (no deprecated top-level) ===
tls {
  defaults {
    ca_file         = "__TLS_CA_FILE__"
    cert_file       = "__TLS_CERT_FILE__"
    key_file        = "__TLS_KEY_FILE__"
    verify_incoming = true
    verify_outgoing = true
  }
  internal_rpc {
    verify_server_hostname = true
  }
}

auto_encrypt { allow_tls = true }
