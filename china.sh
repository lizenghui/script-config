#!/bin/bash

url='http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest'
file='delegated-apnic-latest'
ofile='chinaip.set'
data=$(cat "$file")
{
	echo "create chnroute hash:net family inet"
	echo "$data" | grep CN | grep ipv4 | awk -F'|' '{printf("add chinaip %s/%d\n", $4, 32-log($5)/log(2))}'
} >$ofile
cat "$ofile"
