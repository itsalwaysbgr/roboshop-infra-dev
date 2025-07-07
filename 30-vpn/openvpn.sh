#!/bin/bash
set -euo pipefail

# Redirect all script output to a log file
exec > >(tee -a /var/log/openvpn_setup.log) 2>&1
echo "Starting OpenVPN setup script at $(date)"

SCRIPTS="/usr/local/openvpn_as/scripts"
USERNAME="openvpn"
PASSWORD='Openvpn@123'    # Use SSM or Secrets Manager in production

echo "Waiting for Access Server UI to be ready..."
until curl -ks https://127.0.0.1:943/ >/dev/null 2>&1; do
  echo "Access Server UI not ready, waiting 3 seconds..."
  sleep 3
done
echo "Access Server UI is ready."

# 1. Accept the license agreement
echo "Accepting license agreement..."
$SCRIPTS/sacli --key 'eula_accepted' --value 'true' ConfigPut || echo "Failed to accept EULA"

# 2. Set admin user and password
echo "Setting admin password for $USERNAME..."
$SCRIPTS/sacli --user "$USERNAME" --new_pass "$PASSWORD" SetLocalPassword || echo "Failed to set password"
echo "Setting superuser property for $USERNAME..."
$SCRIPTS/sacli --user "$USERNAME" --key 'prop_superuser' --value 'true' UserPropPut || echo "Failed to set superuser prop"

# 3. VPN port and protocol
echo "Setting VPN port to 1194..."
$SCRIPTS/sacli --key 'vpn.server.port' --value '1194' ConfigPut || echo "Failed to set VPN port"
echo "Setting VPN protocol to UDP..."
$SCRIPTS/sacli --key 'vpn.server.protocol' --value 'udp' ConfigPut || echo "Failed to set VPN protocol"

# 4. DNS configuration: use Access Server host DNS
echo "Configuring DNS settings..."
$SCRIPTS/sacli --key 'vpn.client.dns.server_auto' --value 'true' ConfigPut || echo "Failed to set client DNS auto"
$SCRIPTS/sacli --key 'cs.prof.defaults.dns.0' --value '8.8.8.8' ConfigPut || echo "Failed to set DNS 0"
$SCRIPTS/sacli --key 'cs.prof.defaults.dns.1' --value '1.1.1.1' ConfigPut || echo "Failed to set DNS 1"

# 5. Route all client traffic through the VPN
echo "Enabling reroute gateway..."
$SCRIPTS/sacli --key 'vpn.client.routing.reroute_gw' --value 'true' ConfigPut || echo "Failed to enable reroute_gw"

# 6. Block access to VPN server services from clients (your latest request)
echo "Enabling gateway access for VPN clients..."
$SCRIPTS/sacli --key 'vpn.server.routing.gateway_access' --value 'true' ConfigPut || echo "Failed to enable gateway access"

echo "Restarting openvpnas service..."
systemctl restart openvpnas || echo "Failed to restart openvpnas service"

# 7. Save and start
echo "Synchronizing configuration..."
$SCRIPTS/sacli ConfigSync || echo "Failed to ConfigSync"
echo "Starting OpenVPN Access Server..."
$SCRIPTS/sacli start || echo "Failed to start Access Server"

echo "OpenVPN setup script finished at $(date)"