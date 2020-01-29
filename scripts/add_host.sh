#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/scripts/_common"


START_IP=${START_IP:-127.0.0.1}
START_HOSTS=${START_HOSTS:-'
  kotlon-config
  kotlon-eureka
  permission-api
  mysql
  redis
'}

set +e

function checkHost() {
  case $(osfamily) in
    darwin)
      #macOS device with Stealth Mode on won't be able to ping localhost so we use dscacheutil instead.
      ! test -z "$(dscacheutil -q host -a name $1)"
      ;;
    linux|*)
      ping -c 1 -w 1 $1 >/dev/null 2>&1
      ;;
  esac
}

function addHost() {
  # Add ip and host to /etc/hosts only if the entry doesn't exist
  host="$1"
  ip="$2"
  hosts_file="/etc/hosts"
  info "Adding entry for $host to $ip in $hosts_file."

  if egrep -q "^#\s*[^\s]+\s+${host}\s+" "$hosts_file"; then
    warning "Host $host exists in $hosts_file, but it is commented out. You need to manually edit $hosts_file."
  elif egrep -q "^[^\s]+\s+${host}\s+" "$hosts_file"; then
    warning "Host $host exists in $hosts_file, but it is not able to be resolved. You need to manually edit $hosts_file."
  else
    printf "%s\t%s\n" "$ip" "$host" | sudo tee -a "$hosts_file" > /dev/null
    if egrep -q "^${ip}\s+${host}$" "$hosts_file"; then
      ok "Host $host added successfully."
    else
      fail "Could not add host $host to $hosts_file. You need to manually edit $hosts_file."
    fi
  fi
}

# Do the mac host alias too
info "Checking local on mac"
if ! checkHost "local"; then
  addHost "local" "10.100.10.1"
else
  ok "Hostname local appears to be working"
fi

for host in $START_HOSTS; do
  info "Checking $host"
  if ! checkHost "$host"; then
    addHost "$host" "$START_IP"
  else
    ok "Hostname $host appears to be working"
  fi
done

ok "All done: hosts in place"