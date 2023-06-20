#! /bin/bash
time=$(date "+%Y%m%d%H%M%S")
ip=$(cat /etc/wireguard/wg0.conf| grep "Endpoint = " | awk -F "Endpoint = " '{print $2}'| awk -F ":" '{print $1}')
port=$(cat /etc/wireguard/wg0.conf| grep "Endpoint = " | awk -F "Endpoint = " '{print $2}'| awk -F ":" '{print $2}')


if [ $port -gt 59999 ]; then
        newport=10000
else
        newport=$((port + 1))
fi

ping -c 2 $ip
if [ $? -eq 0 ]; then
        echo "$time Network is ok!" >> /var/log/vpn.log
else
        sed -i "s/$port/$newport/g" /etc/wireguard/wg0.conf
        systemctl restart wg-quick@wg0
        echo "$time Network is fail!  $newport"  >> /var/log/vpn.log
fi
