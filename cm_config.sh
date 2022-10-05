#!/bin/bash
clear
echo "Welcome to F5 BIGIP Next CM Initial Configurator version 0.0.1a"
echo ""
echo "This script will run you through setting up your BIGIP Next CM"

sleep 5

clear
echo "Now getting the interface for IP address setup of Management Interface:"
ip link | grep ens
sleep 2
echo ""
echo "Please enter the 3 numbers after ens in the interface:"
read INTNUM
INTFCE="ens$INTNUM"
#echo $INTNUM
#echo $INTFCE
NETPATH="network.ethernets"
echo ""
echo "What IP Address do you want assigned:"
read IPADDR
echo "What is the netmask in CIDR notation:"
read CIDR
echo "What is the gateway address:"
read GW
echo "What is nameserver address:"
read NS
echo "What NTP server address will be used:"
read NTP
echo ""
echo "Thank you for this information"
echo ""
echo ""
echo "Interface: $INTFCE"
echo "Netpath: $NETPATH"
echo "IP Addr: $IPADDR"
echo "IP Netmask: $CIDR"
echo "Default Gateway: $GW"
echo "Nameserver: $NS"
echo "NTP Server: $NTP"
sleep 7
clear
sudo /bin/bash <<EOF
echo "Disabling Cloud Init..."
echo "network: {config: disabled}" | tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg > /dev/null
echo ""
sleep 1
echo "Disabling DHCP..."
netplan set $NETPATH.$INTFCE.dhcp4=no
sleep 1
echo "Setting IP address and netmask..."
netplan set $NETPATH.$INTFCE.addresses=[$IPADDR/$CIDR]
sleep 1
echo "Setting up default gateway..."
netplan set $NETPATH.$INTFCE.gateway4=$GW
sleep 1
echo "Setting up nameservers..." 
netplan set $NETPATH.$INTFCE.nameservers.addresses=[$NS]
sleep 1
echo "IP address has been configured."
netplan apply
echo ""
sleep 1
ip addr
sleep 5
echo "Setting up NTP..."
echo "NTP=$NTP" >> /etc/systemd/timesyncd.conf
sleep 1
echo "Restarting NTP..."
systemctl restart systemd-timesyncd
sleep 1
echo "Basic management address configuration is complete. We will now execute the cm install routine which will build out the BIGIP Next CM and get it up and running. When complete we will execute the k8s command to verify that BIGIP CM is running."
echo ""
echo ""
EOF
sleep 2
/opt/cm-bundle/cm install
kubectl get pods

sleep 5
kubctl get pods
sleep 2
echo ""
echo ""
echo "IP address: "
ip addr

clear
echo "If all completed you should be able to access your BIGIP Next CM at https://$IPADDR with the login of admin/admin" 
echo ""
echo ""
echo "Thank you for using the WWT GS&A BIGIP Next CM install script."
