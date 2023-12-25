# Cychat Server

  This repository contains a bash script for Ubuntu server that allows you to manage a DHCP server and an SSH server. It's main feature is to enable/disable all possible screenshots from a Windows client. This script is useful for chat desktop applications that communicate through LAN. It's my first ever project for my final year. 
![Screenshot 2023-12-25 141128](https://github.com/noexistper/Cychat/assets/108919761/4ca2a14d-e985-466e-a017-cbdd14397666)

![Screenshot 2023-12-25 141146](https://github.com/noexistper/Cychat/assets/108919761/102339c0-432c-4f1e-a7cb-20f96a61625d)

  
# Steps for Server
  1) Download and install ubuntu server from https://ubuntu.com/download/server#downloads
  2) Clone script using following command :::     git clone https://github.com/noexistper/Cychat
  3) Run script using :::     sudo bash Cychat.sh
  4) It asks for all required packages, just enter "Y" to install
  5) After that you will see main menu.
     
# Steps for Client
  1) Install feature "Openssh". from settings>system>optional features
  2) Also allow server in firewall.
     
# And there you go ready for using the script.
a) I used ubuntu server.
b) It can be problematic for other linux distributions.
c) My clients were windows 10 devices.


I hope it helps you for your projects :)
