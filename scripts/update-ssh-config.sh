#!/usr/bin/env bash
set -euo pipefail

TERRAFORM_DIR="$(cd "$(dirname "$0")/../terraform" && pwd)"
SSH_CONFIG="$HOME/.ssh/config"
IDENTITY_FILE="$HOME/.ssh/ansible_hetzner"
MARKER_START="# BEGIN ansible-hetzner"
MARKER_END="# END ansible-hetzner"

cd "$TERRAFORM_DIR"

if ! terraform output -json &>/dev/null; then
  echo "Error: no terraform state found. Run terraform apply first." >&2
  exit 1
fi

WEBSERVER_IPS=$(terraform output -json webserver_ips | python3 -c "import sys,json; [print(ip) for ip in json.load(sys.stdin)]")
DBSERVER_IP=$(terraform output -raw dbserver_ip)

build_block() {
  local idx=1
  echo "$MARKER_START"
  for ip in $WEBSERVER_IPS; do
    cat <<EOF

Host web$(printf "%02d" $idx)
  HostName $ip
  User ansible
  IdentityFile $IDENTITY_FILE
  IdentitiesOnly yes
  StrictHostKeyChecking no
EOF
    idx=$((idx + 1))
  done

  cat <<EOF

Host db01
  HostName $DBSERVER_IP
  User ansible
  IdentityFile $IDENTITY_FILE
  IdentitiesOnly yes
  StrictHostKeyChecking no
EOF
  echo "$MARKER_END"
}

touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

# Remove existing block if present
if grep -q "$MARKER_START" "$SSH_CONFIG"; then
  sed -i "/$MARKER_START/,/$MARKER_END/d" "$SSH_CONFIG"
fi

build_block >> "$SSH_CONFIG"

echo "Updated $SSH_CONFIG:"
grep -A 100 "$MARKER_START" "$SSH_CONFIG" | grep -B 100 "$MARKER_END"
