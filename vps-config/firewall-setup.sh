#!/bin/bash
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw allow 51820/udp
ufw enable
