
ip rule add fwmark 1 table 100 
ip route add local 0.0.0.0/0 dev lo table 100

iptables -t mangle -N V2RAY
iptables -t mangle -A V2RAY -d 127.0.0.1/32 -j RETURN
iptables -t mangle -A V2RAY -d 224.0.0.0/4 -j RETURN 
iptables -t mangle -A V2RAY -d 255.255.255.255/32 -j RETURN 
iptables -t mangle -A V2RAY -d 192.168.0.0/16 -p tcp -j RETURN
iptables -t mangle -A V2RAY -d 192.168.0.0/16 -p udp ! --dport 53 -j RETURN
iptables -t mangle -A V2RAY -p udp -j TPROXY --on-port 12345 --tproxy-mark 1
iptables -t mangle -A V2RAY -p tcp -j TPROXY --on-port 12345 --tproxy-mark 1
iptables -t mangle -A PREROUTING -j V2RAY

iptables -t mangle -N V2RAY_MASK 
iptables -t mangle -A V2RAY_MASK -d 224.0.0.0/4 -j RETURN 
iptables -t mangle -A V2RAY_MASK -d 255.255.255.255/32 -j RETURN 
iptables -t mangle -A V2RAY_MASK -d 192.168.0.0/16 -p tcp -j RETURN
iptables -t mangle -A V2RAY_MASK -d 192.168.0.0/16 -p udp ! --dport 53 -j RETURN
iptables -t mangle -A V2RAY_MASK -j RETURN -m mark --mark 0xff
iptables -t mangle -A V2RAY_MASK -p udp -j MARK --set-mark 1
iptables -t mangle -A V2RAY_MASK -p tcp -j MARK --set-mark 1
iptables -t mangle -A OUTPUT -j V2RAY_MASK
