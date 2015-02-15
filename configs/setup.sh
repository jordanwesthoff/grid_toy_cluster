#!/bin/bash

# Plain Vanilla Cluster (PVC) Configuration script setup.sh 
# Copyright (C) 2013 Glen E. Gardner Jr.
# 
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
echo " "
echo "setup,sh Copyright (C) 2013 Glen E. Gardner Jr."
echo "This program comes with ABSOLUTELY NO WARRANTY; "
echo "This is free software, and you are welcome to redistribute it."
echo "under certain conditions as outlined in the GNU GENERAL PUBLIC LICENSE."
echo " "


SET_PATH=/root/configs
NAME_1=p0
IP_ADDR=192.168.1.40
NET_MASK=255.255.255.0
NET_GATEWAY=192.168.1.1
NAMESERVER=192.168.1.1


chown -R root:root $SET_PATH

# configure the ethernet

MAC_ADDR=`ifconfig eth0 | awk '/HWaddr/ {print $5}'`
echo "DEVICE=eth0" > $SET_PATH/common/etc/sysconfig/network-scripts/ifcfg-eth0
echo "TYPE=Ethernet" >> $SET_PATH/common/etc/sysconfig/network-scripts/ifcfg-eth0
echo "ONBOOT=yes" >> $SET_PATH/common/etc/sysconfig/network-scripts/ifcfg-eth0
echo "NM_CONTROLLED=no" >> $SET_PATH/common/etc/sysconfig/network-scripts/ifcfg-eth0
echo "BOOTPROTO=static" >> $SET_PATH/common/etc/sysconfig/network-scripts/ifcfg-eth0
echo "IPV6INIT=no" >> $SET_PATH/common/etc/sysconfig/network-scripts/ifcfg-eth0
echo "HWADDR="$MAC_ADDR >> $SET_PATH/common/etc/sysconfig/network-scripts/ifcfg-eth0
echo "MTU=1492" >> $SET_PATH/common/etc/sysconfig/network-scripts/ifcfg-eth0
echo "IPADDR="$IP_ADDR >> $SET_PATH/common/etc/sysconfig/network-scripts/ifcfg-eth0
echo "NETMASK="$NET_MASK >> $SET_PATH/common/etc/sysconfig/network-scripts/ifcfg-eth0
echo "GATEWAY="$NET_GATEWAY >> $SET_PATH/common/etc/sysconfig/network-scripts/ifcfg-eth0


#create the hosts file
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > $SET_PATH/common/etc/hosts
echo "192.168.1.40  p0" >> $SET_PATH/common/etc/hosts
echo "192.168.1.50  p1" >> $SET_PATH/common/etc/hosts
echo "192.168.1.60  p2" >> $SET_PATH/common/etc/hosts
echo "192.168.1.70  p3" >> $SET_PATH/common/etc/hosts
echo "192.168.1.80  p4" >> $SET_PATH/common/etc/hosts
echo "192.168.1.90  p5" >> $SET_PATH/common/etc/hosts
echo "192.168.1.100 p6" >> $SET_PATH/common/etc/hosts
echo "192.168.1.110 p7" >> $SET_PATH/common/etc/hosts
echo "192.168.1.10 phoenix" >> $SET_PATH/common/etc/hosts

# create the /etc/sysconfig/network file
echo "NETWORKING=yes" > $SET_PATH/common/etc/sysconfig/network
echo "HOSTNAME="$NAME_1 >> $SET_PATH/common/etc/sysconfig/network
echo "GATEWAY="$NET_GATEWAY >> $SET_PATH/common/etc/sysconfig/network

# backup the /etc/fstab to comp 
cp -f /etc/fstab $SET_PATH/comp/etc/fstab

# copy the default user environment scripts to /etc/skel
#cp -fp $SET_PATH/common/etc/skel/. /etc/skel/.


# you really don't want the extra latency of iptables, but if used
# it must be configured to allow ssh , nfs and mpich to communicate.
# here we configure it to allow ports 10000-10100 for use by mpich
cp -rfp $SET_PATH/head/etc/sysconfig/iptables /etc/sysconfig/iptables


service NetworkManager stop

# if name is p0 configure a head node
# if name is not p0 configure a compute node

if  echo $NAME_1| grep "p0" > /dev/null
then
{
echo "Configuring head node"
cp -rfp $SET_PATH/head/etc/.  /etc/.
chkconfig nfs on
mkdir /home/common
chmod 755 -R /home/common
cp -rfp $SET_PATH/head/home/pvcuser/.ssh /home/pvcuser/.
cp -fp $SET_PATH/head/home/pvcuser/.bash_profile /home/pvcuser/.
service nfs start
}
else
{
echo "Configuring compute node"
echo "p0:/home /home nfs rw 0 0" >> $SET_PATH/comp/etc/fstab
cp -rfp $SET_PATH/comp/etc/. /etc/.
}
fi

chown -R pvcuser:pvcuser /home/pvcuser

chkconfig firstboot off
chkconfig bluetooth off
chkconfig abrtd off
chkconfig iscsi off
chkconfig iscsid off
chkconfig cups off
chkconfig NetworkManager off
chkconfig network on
chkconfig cpuspeed off
chkconfig ntpd on


cp -rfp $SET_PATH/common/etc/. /etc/.
cp -rfp $SET_PATH/common/root/. /root/.


echo "nameserver "$NAMESERVER > $SET_PATH/common/etc/resolv.conf
cp -f $SET_PATH/common/etc/resolv.conf /etc/resolv.conf

service iptables restart
service network restart
service ntpd start

