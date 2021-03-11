#!/bin/sh

# /etc/network/if-up.d

if [ "$IFACE" = wlx7ca7b0b680d8 ]; then
  ip route add default via 10.0.248.1 dev wlx7ca7b0b680d8 table 10
  rule_exist=$(ip rule | grep "192.168.254.1" | grep -c "10")
  if [ "$rule_exist" -lt "1" ]; then
	ip rule add from 192.168.254.1 table 10
  fi
  iptables_exist=$(iptables -t nat -vL POSTROUTING | grep "MASQUERADE" | grep -c "wlx7ca7b0b680d8")
  if [ "$iptables_exist" -lt "1" ]; then
	iptables -t nat -A POSTROUTING -o wlx7ca7b0b680d8 -j MASQUERADE
  fi
fi
