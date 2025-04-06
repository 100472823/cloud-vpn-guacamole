#!/bin/bash
# Setup LXC Container para Apache Guacamole
pct create 110 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname guacamole-container \
  --net0 name=eth0,bridge=vmbr0,ip=192.168.0.164/24,gw=192.168.0.1 \
  --storage local-lvm \
  --password yourpassword \
  --unprivileged 1

pct start 110
pct exec 110 -- bash -c "apt update && apt install -y curl wget nano cifs-utils"
