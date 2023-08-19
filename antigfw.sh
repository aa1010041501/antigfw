#! /bin/bash
#列出当前时间
time=$(date "+%Y%m%d%H%M%S")
#获取当前配置文件中的ip地址和端口
ip=$(cat /etc/wireguard/wg0.conf| grep "Endpoint = " | awk -F "Endpoint = " '{print $2}'| awk -F ":" '{print $1}')
port=$(cat /etc/wireguard/wg0.conf| grep "Endpoint = " | awk -F "Endpoint = " '{print $2}'| awk -F ":" '{print $2}')

#判断端口号，如果是60000及以上，将新端口号定义为10000.如果不是将端口号+1，作为新端口号。
if [ $port -gt 59999 ]; then
        newport=10000
else
        newport=$((port + 1))
fi
#连续ping两次endpoint ip地址。判断是否正常
ping -c 2 $ip
if [ $? -eq 0 ]; then
        #正常，写入日志。
        echo "$time Network is ok!" >> /var/log/vpn.log
else
        #不正常，更改端口号，重启wireguard。写入日志。
        sed -i "s/$port/$newport/g" /etc/wireguard/wg0.conf
        systemctl restart wg-quick@wg0
        echo "$time Network is fail!  $newport"  >> /var/log/vpn.log
fi
