#!/bin/bash

introtheme() {
 echo -e "
							 ██████╗██╗   ██╗ ██████╗██╗  ██╗ █████╗ ████████╗
							██╔════╝╚██╗ ██╔╝██╔════╝██║  ██║██╔══██╗╚══██╔══╝
							██║      ╚████╔╝ ██║     ███████║███████║   ██║   
							██║       ╚██╔╝  ██║     ██╔══██║██╔══██║   ██║   
							╚██████╗   ██║   ╚██████╗██║  ██║██║  ██║   ██║   
							 ╚═════╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝                                                    
 "
echo "	                                                                 -S E R V E R-"
}

checkpackages() {
dpkg -s $1 &> /dev/null
if [ $? -eq 0 ]; then
    echo "$1 is installed!"
else
    echo "Package $1 is NOT installed!"
    echo "Want to install, (Y,n):"
    read installchoice
    if [ $installchoice = "Y" -o $installchoice = "y" ]; 
     then
	apt-get install $1 -y
    elif [ $installchoice = "N" -o $installchoice = "n" ]; 
	then
	echo "Can't go any further without required tools, exiting....."
	sleep 1
	exit
    else
	echo "Invalid Input,exiting...."
	exit
    fi
fi
}

etherneterror() {
echo "#  Finding error......"
sleep 1
echo "FOUND !!"
echo "Applying solutions....."
sed -i 's/managed=false/managed=true/ ' /etc/NetworkManager/NetworkManager.conf
echo "[keyfile]" >> /etc/NetworkManager/NetworkManager.conf
echo "unmanaged-devices= none" >> /etc/NetworkManager/NetworkManager.conf
sleep 1
echo "Done"
}

requiredbindingdhcptonetwork () {
echo "Binding DHCP-Server to Network Interface"
temp=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")
truncate -s 0 /etc/default/isc-dhcp-server
echo -e '
# Defaults for isc-dhcp-server (sourced by /etc/init.d/isc-dhcp-server)

# Path to dhcpds config file (default: /etc/dhcp/dhcpd.conf).
#DHCPDv4_CONF=/etc/dhcp/dhcpd.conf
#DHCPDv6_CONF=/etc/dhcp/dhcpd6.conf

# Path to dhcpds PID file (default: /var/run/dhcpd.pid).
#DHCPDv4_PID=/var/run/dhcpd.pid
#DHCPDv6_PID=/var/run/dhcpd6.pid

# Additional options to start dhcpd with.
#       Dont use options -cf or -pf here; use DHCPD_CONF/ DHCPD_PID instead
#OPTIONS=""

# On what interfaces should the DHCP server (dhcpd) serve DHCP requests?
#       Separate multiple interfaces with spaces, e.g. "eth0 eth1".
INTERFACESv4="'"$temp"'"
INTERFACESv6=""
' >> /etc/default/isc-dhcp-server
sleep 1
echo "done"
}

requiredsubmaskgateways() {
echo "Setting ip addresses......"
echo "Enter subnet:"
read subnet
echo "Enter minimum-range (example: 192.168.7.min):"
read minrange
echo "Enter maximum-range (example: 192.168.7.max):"
read maxrange
echo "Enter gateway:"
read gateway
echo "Enter broadcast-address:"
read broadcastaddress
truncate -s 0 /etc/dhcp/dhcpd.conf
echo -e "
default-lease-time 600;
max-lease-time 7200;
# If this DHCP server is the official DHCP server for the local
# network, the authoritative directive should be uncommented.
authoritative;
# A slightly different configuration for an internal subnet.
subnet "$subnet" netmask 255.255.255.0 {
  range "$minrange" "$maxrange";
#  option domain-name-servers ns1.internal.example.org;
#  option domain-name "internal.example.org";
  option routers "$gateway";
  option broadcast-address "$broadcastaddress";
  default-lease-time 600;
  max-lease-time 7200;
}
 " >> /etc/dhcp/dhcpd.conf
echo "Applying changes...."
sleep 1

echo "Done"
}

applyfixip() {
echo "Enter Host Name:"
read hostname
echo "Enter Mac Address( 01:02:03:04:05:06 ):"
read macaddress
echo "Enter Ip Address:"
read ippaddress
echo -e "
host "$hostname" {
  hardware ethernet "$macaddress";
  fixed-address "$ippaddress";
}

 " >> /etc/dhcp/dhcpd.conf

}

givestaticip() {

echo "Setting Static ip-addresses......"
echo "Enter ip-address:"
read ipaddress
echo "Enter gateway:"
read gateway
temp=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")
truncate -s 0 /etc/netplan/00-installer-config.yaml
echo -e "
network:
    version: 2
    renderer: networkd
    ethernets:
         $temp:
            dhcp4: no
            addresses: ["$ipaddress"/24]
            gateway4: "$gateway"
            nameservers:
                addresses: [8.8.8.8,8.8.4.4]

" >> /etc/netplan/00-installer-config.yaml
echo "Applying settings...."
sleep 1
echo "Applying settings......"
sleep 1
echo "Applying settings........"
netplan generate
netplan apply
systemctl restart NetworkManager.service
sleep 1
echo "done..."

}

connecttointernet() {

temp=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")
truncate -s 0 /etc/netplan/00-installer-config.yaml
echo -e "
network:
    version: 2
    renderer: networkd
    ethernets:
        $temp:
            dhcp4: yes
" >> /etc/netplan/00-installer-config.yaml
echo "Applying settings...."
sleep 1
echo "Applying settings......"
sleep 1
echo "Applying settings........"
netplan generate
netplan apply
systemctl restart NetworkManager.service
sleep 1
echo "done..."

}

disabless() {

 read -p "Enter the username of the client: " USERNAME
 read -p "Enter the IP address of the client: " IP_ADDRESS


 if [[ $IP_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    

    ssh $USERNAME@$IP_ADDRESS 'reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /t REG_BINARY /d "0000000000000000040000002AE037E0000037E00000540000000000" /f'

    ssh $USERNAME@$IP_ADDRESS 'reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisabledHotkeys" /t REG_SZ /d "S" /f'

    ssh $USERNAME@$IP_ADDRESS 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SnippingTool.exe" /v Debugger /t REG_SZ /d "notepad.exe" /f'

    ssh $USERNAME@$IP_ADDRESS "reg add \"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\" /v "ShowTabletKeyboard" /t REG_DWORD /d 0 /f"
    ssh $USERNAME@$IP_ADDRESS 'move /y "C:\Windows\System32\osk.exe" "C:\Windows\Web" '
    ssh $USERNAME@$IP_ADDRESS 'move /y "C:\Windows\System32\OskSupport.dll"  "C:\Windows\Web" '
    echo "   "
    echo "   "
    echo "Screenshots are disabled on $IP_ADDRESS for user $USERNAME."
    echo "Restarting $USERNAME for changes to apply correctly."
    ssh $USERNAME@$IP_ADDRESS "shutdown /r /t 0"

 else
    echo "Invalid IP address: $IP_ADDRESS"
 fi

}
enableprtsrc() {

 read -p "Enter the username of the client: " USERNAME
 read -p "Enter the IP address of the client: " IP_ADDRESS

 if [[ $IP_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then

  ssh $USERNAME@$IP_ADDRESS 'reg delete "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /f'

  echo "PrtSrc Enabled on $IP_ADDRESS for user $USERNAME."
  echo "Restarting $USERNAME for  changes to apply correctly."
  ssh $USERNAME@$IP_ADDRESS "shutdown /r /t 0"

 else
    echo "Invalid IP address: $IP_ADDRESS"
 fi

}

enablesnippingtool() {

read -p "Enter the username of the client: " USERNAME
read -p "Enter the IP address of the client: " IP_ADDRESS

if [[ $IP_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then

    ssh $USERNAME@$IP_ADDRESS  'reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SnippingTool.exe" /f'

    ssh $USERNAME@$IP_ADDRESS 'reg delete "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisabledHotkeys" /f'

    echo "SnippingTool has been recovered for $IP_ADDRESS."
    echo " Restarting $USERNAME for changes to apply correctly."
    ssh $USERNAME@$IP_ADDRESS "shutdown /r /t 0"

else
    echo "There was a problem disabling the on-screen keyboard service."
fi

}

enableonscreenkeyboard() {

read -p "Enter the username of the client: " USERNAME
read -p "Enter the IP address of the client: " IP_ADDRESS

if [[ $IP_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then


    ssh $USERNAME@$IP_ADDRESS "reg delete \"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\" /v "ShowTabletKeyboard" /f"
    ssh $USERNAME@$IP_ADDRESS 'move /y "C:\Windows\Web\osk.exe" "C:\Windows\System32" '
    ssh $USERNAME@$IP_ADDRESS 'move /y "C:\Windows\Web\OskSupport.dll" "C:\Windows\System32" '
    echo "On-Screen Keyboard is recovered for $USERNAME"
    echo " Restarting $USERNAME for changes to apply correctly."
    ssh $USERNAME@$IP_ADDRESS "shutdown /r /t 0"

 else
    echo "Invalid IP address: $IP_ADDRESS"
 fi


}

nextpage() {

while true;
do
 read -rsn1 -p "Press any key to continue..."
 clear
 introtheme
 echo -e "
			   -Configure Network-manager-				-DHCP Manipulation-				-SSH Settings-

				1) nmtui				  A) Enable/Start DHCP 				a) Check SSH connection to any client
				2) Restart Network			  B) Disable DHCP				b) Generate Public key for a client 
				3) Set static ip-address		  C) nano nano /etc/default/isc-dhcp-server
                                4) Connect to Internet		          D) nano /etc/dhcp/dhcpd.conf
				5) Getting 1) empty? Fix		  E) Check current ip-address



			[PAGE:2/2] Y) Go to first page								X) EXIT
"
read -p "			Your Choice:" menuchoice
case $menuchoice in
	A) systemctl disable isc-dhcp-server;;
	B) systemctl enable isc-dhcp-server && systemctl start isc-dhcp-server;;
	C) nano /etc/default/isc-dhcp-server;;
	D) nano /etc/dhcp/dhcpd.conf;;
	E) ip a;;
	1) nmtui;;
	2) systemctl restart NetworkManager.service;;
	3) givestaticip;;
	4) connecttointernet;;
	5) etherneterror;;
	Y) firstpage;;
	x|X) exit;;
esac
done



}

firstpage() {

while true;
do
 read -rsn1 -p "Press any key to continue..."
 clear
 introtheme
 echo -e "
			  -SERVER Manipulation-				  -DHCP Manipulation-				  -Client Manipulation -

			A) Check DHCP-Server status			a) Bind DHCP to Network 			1) Block PrtScr/ snippingtool
			B) List the connected clients			b) Apply subnet, gateways			2) Enable PrtScr 
			C) Restart DHCP Server				c) Check current ipaddress			3) Enable SnippingTool
			D) Fixed Ip address to clients	 	 							4) Enable OnScreen-Keyboard
												                        5) SSH Server status
															6) Restart SSH Server
			 							                                


			[PAGE:1/2] Y) Go to next page												X) EXIT
"
read -p "			Your Choice:" menuchoice
case $menuchoice in
	A) systemctl status isc-dhcp-server;;
	B) dhcp-lease-list --lease /var/lib/dhcpd/dhcpd.leases;;
	C) systemctl restart isc-dhcp-server;;
	D) applyfixip;;
	a) requiredbindingdhcptonetwork;;
	b) requiredsubmaskgateways;;
	c) ip a;;
	1) disabless;;
	2) enableprtsrc;;
	3) enablesnippingtool;;
	4) enableonscreenkeyboard;;
	5) systemctl status ssh;;
	6) systemctl restart ssh;;
	Y) nextpage;;
	x|X) exit;;
esac
done

}






clear
if [ "$EUID" -ne 0 ]
 then 
 echo "Root Access is REQUIRED !!!"
 exit
else
 checkpackages isc-dhcp-server
 clear
 checkpackages net-tools
 clear
 checkpackages network-manager
 clear
 checkpackages iputils-ping
 clear
 checkpackages openssh-client
 clear 
 ufw allow ssh
 ufw enable
 clear
 echo "You got tools Required."
 firstpage
fi
