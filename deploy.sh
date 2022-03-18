#!/bin/bash
# We assume that you have booted the live iso at a new gentoo machine
# and grabbed this script from https://smurfd.serveblog.net/gentoo/deploy_gentoo.sh
# THIS WILL WIPE YOUR DRIVE

source ./setup.cfg

# Add some config files or parts of configfiles to $SITE/ for easily be able to wget

CRASHANDBURN=isolomlyswearimuptono.good
if test -f "$CRASHANDBURN"; then
  echo 'Its Your fault from now on...'
else
  echo 'DO YOU REALIZE THIS WILL WIPE YOUR DRIVE???'
  echo 'if you do, and you understand that anything that goes wrong after this, is YOUR FAULT!'
  echo 'Read through the script and change the variables at the top to your liking'
  echo 'Then run the following command and re-run the script:'
  echo 'touch isolomlyswearimuptono.good'
  exit
fi

# Configure network for the install
ifconfig $NC $IP 192.168.0.255 netmask 255.255.255.0 up
route add default gw 192.168.0.1
echo 'nameserver 192.168.0.1' >> /etc/resolv.conf

# Set keyboard
echo 'keymap="sv-latin1"' >> /etc/conf.d/keymaps
/etc/init.d/keymaps restart

# Wipe filesystem
wipefs $HD

# Create partitions
parted -a optimal $HD --script mklabel gpt
parted $HD --script unit MB                   #Sets the unit to MegaBytes
parted $HD --script mkpart primary 1 20       #Makes a primary partition starting from 1 MegaByte to #20th for bios
parted $HD --script mkpart primary 21 500     #Partition /boot filesystem
parted $HD --script mkpart primary 501 7500   #Partition of size 2000MB made for swap
parted $HD --script mkpart primary 7501 107500    #Partition for the /(root) filesystem.
parted $HD --script -- mkpart primary 107501 -1   # partition for the rest of the disk /home
parted $HD --script print
parted $HD --script name 1 grub
parted $HD --script set 1 bios_grub on        #The partition number 1 has its bios_grub flag set to one
parted $HD --script name 2 boot
parted $HD --script name 3 swap
parted $HD --script name 4 root
parted $HD --script name 5 home

# Create the filesystems
mkfs.ext4 "${HDD}4" 
mkfs.ext4 "${HDD}5"
mkfs.fat -F 32 "${HDD}2"
mkswap "${HDD}3"
swapon "${HDD}3"

# Mounting the root partition
mount "${HDD}4" /mnt/gentoo

# Create and make the boot partition
mkdir /mnt/gentoo/boot
mkdir /mnt/gentoo/boot/efi
mkdir /mnt/gentoo/home
mount "${HDD}2" /mnt/gentoo/boot/efi
mount "${HDD}5" /mnt/gentoo/home

cp setup.cfg deploy-chroot.sh /mnt/gentoo
chmod +x /mnt/gentoo/deploy-chroot.sh

# Get the latest stage3 file
cd /mnt/gentoo
wget $URL/latest-stage3-amd64-hardened-openrc.txt
URL2=`cat latest-stage3-amd64-hardened-openrc.txt|grep -v "^#" | cut -d" " -f1`
wget $URL/$URL2

# unpack the tarball
tar xpf stage3-amd64* --xattrs-include='*.*' --numeric-owner

# Create a make.conf
echo '# These settings were set by the catalyst build script that automatically' > /mnt/gentoo/etc/portage/make.conf
echo '# built this stage.' >> /mnt/gentoo/etc/portage/make.conf
echo '# Please consult /usr/share/portage/config/make.conf.example for a more' >> /mnt/gentoo/etc/portage/make.conf
echo '# detailed example.' >> /mnt/gentoo/etc/portage/make.conf
echo 'COMMON_FLAGS="-march=native -O2 -pipe"' >> /mnt/gentoo/etc/portage/make.conf
echo 'CFLAGS="${COMMON_FLAGS}"' >> /mnt/gentoo/etc/portage/make.conf
echo 'CXXFLAGS="${COMMON_FLAGS}"' >> /mnt/gentoo/etc/portage/make.conf
echo 'FCFLAGS="${COMMON_FLAGS}"' >> /mnt/gentoo/etc/portage/make.conf
echo 'FFLAGS="${COMMON_FLAGS}"' >> /mnt/gentoo/etc/portage/make.conf
echo 'MAKEOPTS="-j4"' >> /mnt/gentoo/etc/portage/make.conf
echo '' >> /mnt/gentoo/etc/portage/make.conf
echo '# NOTE: This stage was built with the bindist Use flag enabled' >> /mnt/gentoo/etc/portage/make.conf
echo 'PORTDIR="/var/db/repos/gentoo"' >> /mnt/gentoo/etc/portage/make.conf
echo 'DISTDIR="/var/cache/distfiles"' >> /mnt/gentoo/etc/portage/make.conf
echo 'PKGDIR="/var/cache/binpkgs"' >> /mnt/gentoo/etc/portage/make.conf
echo '' >> /mnt/gentoo/etc/portage/make.conf
echo '# This sets the language of build output to English.' >> /mnt/gentoo/etc/portage/make.conf
echo '# Please keep this setting intact when reporting bugs.' >> /mnt/gentoo/etc/portage/make.conf
echo 'LC_MESSAGES=C' >> /mnt/gentoo/etc/portage/make.conf
if [ $LOCAL = true ]; then
echo 'GENTOO_MIRRORS="rsync://192.168.0.10/gentoo"' >> /mnt/gentoo/etc/portage/make.conf
else
echo 'GENTOO_MIRRORS="http://gentoo.osuosl.org/"' >> /mnt/gentoo/etc/portage/make.conf
fi
echo 'ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"' >> /mnt/gentoo/etc/portage/make.conf

# Create a portage folder
mkdir --parents /mnt/gentoo/etc/portage/repos.conf && cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf && cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mkdir --parents /mnt/gentoo/var/db/repos/gentoo

# Set local rsync mirror
if [ $LOCAL = true ]; then
sed -i 's/sync-uri = rsync:\/\/rsync.gentoo.org\/gentoo-portage/sync-uri = rsync:\/\/192.168.0.10\/gentoo-portage/g' /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
fi

# Mount the system partitions
mount --types proc /proc /mnt/gentoo/proc &&  mount --rbind /sys /mnt/gentoo/sys && mount --make-rslave /mnt/gentoo/sys && mount --rbind /dev /mnt/gentoo/dev && mount --make-rslave /mnt/gentoo/dev

# Enter chroot
chroot /mnt/gentoo ./deploy-chroot.sh 

# Clearing out some downloaded things from the chroot 
rm /mnt/gentoo/deploy.sh
rm /mnt/gentoo/deploy-chroot.sh
rm /mnt/gentoo/kernel.cfg
rm /mnt/gentoo/latest*.txt
rm /mnt/gentoo/stage*

# Unmount After install in chroot is done
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -l /mnt/gentoo{/boot/efi,/proc,}

echo "Now you should be able to reboot" 
