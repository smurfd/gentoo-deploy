#!/bin/sh
echo "URL=https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds" > setup.cfg
echo "SITE=https://smurfd.serveblog.net/g/" >> setup.cfg
echo "IP=$1"  >> setup.cfg # 192.168.0.66
echo "DNS=$2" >> setup.cfg # monkey
echo "NIS=$3" >> setup.cfg # island
echo "HOST=$4" >> setup.cfg # ghost
echo "NC=$5" >> setup.cfg # enp2s0
echo "HD=$6" >> setup.cfg # /dev/sda
echo "HDD=$7" >> setup.cfg # /dev/nvme0n1
echo "ROOTPW=iisl33thaxx0rm3_" >> setup.cfg
echo "USR=$8" >> setup.cfg # blowfish
echo "USRPW=$9" >> setup.cfg #iisn00bN0H473
echo "LOCAL=true" >> setup.cfg
echo "KVM=true" >> setup.cfg

wget -quiet https://raw.githubusercontent.com/smurfd/gentoo-deploy/main/deploy.sh
wget -quiet https://raw.githubusercontent.com/smurfd/gentoo-deploy/main/deploy-chroot.sh
wget -quiet https://raw.githubusercontent.com/smurfd/gentoo-deploy/main/kernel.cfg
wget -quiet https://raw.githubusercontent.com/smurfd/gentoo-deploy/main/kernel-kvm.cfg

sh ./deploy.sh
