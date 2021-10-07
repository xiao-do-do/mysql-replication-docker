#!/bin/bash
if grep -q "net.ipv4.ip_forward" /usr/lib/sysctl.d/00-system.conf
then
 echo "forward=1"
else
    echo "net.ipv4.ip_forward=1" >> /usr/lib/sysctl.d/00-system.conf
fi

#if cat /usr/lib/sysctl.d/00-system.conf  | grep net.ipv4.ip_forward >/dev/null
#then
#	echo "net.ipv4.ip_forward=1" >> /usr/lib/sysctl.d/00-system.conf
#        echo "no"
#else
#        echo "yes"
#fi
#
service network restart
docker exec -i mysql /bin/bash -c "cd / | chmod +x slave.sh | ./slave.sh"

