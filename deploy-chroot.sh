#!/bin/bash

source ./setup.cfg
source /etc/profile && export PS1="(chroot) ${PS1}"
emerge --sync

# Set the Hardened profile
eselect profile set 3

# Update @world
emerge --verbose --update --deep --newuse @world --quiet

# Set timezone
echo 'Europe/Stockholm' > /etc/timezone
emerge --config sys-libs/timezone-data

echo 'en_US ISO-8859-1' > /etc/locale.gen
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
echo 'sv_SE ISO-8859-1' >> /etc/locale.gen
echo 'sv_SE.UTF-8 UTF-8' >> /etc/locale.gen
echo 'C.UTF8 UTF-8' >> /etc/locale.gen

locale-gen && eselect locale set 6 && env-update && source /etc/profile

# Make a /etc/fstab file
echo "${HDD}2   /boot/efi    ext4    defaults, noatime    0 2" > /etc/fstab
echo "${HDD}3   none         swap    sw                   0 0" >> /etc/fstab
echo "${HDD}4   /            ext4    noatime              0 1" >> /etc/fstab

# Emerge the kernel & genkernel
emerge --quiet sys-kernel/gentoo-sources sys-kernel/genkernel

# Create symlink
cd /usr/src/
ln -s linux* linux

# Compile the kernel
if [ $KVM = false ]; then
# wget $SITE/kernel.cfg
genkernel --kernel-config=/kernel.cfg all
else
# wget $SITE/kernel-kvm.cfg
genkernel --kernel-config=/kernel-kvm.cfg all
fi

# Set hostname / domain
echo "hostname=${HOST}" > /etc/conf.d/hostname

echo "dns_domain_lo=${DNS}" > /etc/conf.d/net
echo "nis_domain_lo=${NIS}" >> /etc/conf.d/net
echo "config_"${NC}"="${IP}'" netmask 255.255.255.0 brd 192.168.0.255"' >> /etc/conf.d/net
echo "routes_"${NC}"="'"default via 192.168.0.1"' >> /etc/conf.d/net

# Configure the network
emerge --quiet --noreplace net-misc/netifrc

cd /etc/init.d && ln -s net.lo net.$NC && rc-update add net.$NC default
echo "${IP} ${HOST}.${DNS} ${HOST}" >> /etc/hosts

# Set root pw
echo root:$ROOTPW | chpasswd

# Set Swedish keyboard
echo 'keymap="sv-latin1"' >> /etc/conf.d/keymaps
/etc/init.d/keymaps restart

echo 'USE="logrotate elogind nftables xtables dbus symlink -sendmail"' >> /etc/portage/make.conf

# Install some systemtools
emerge -vD sysklogd cronie e2fsprogs mlocate openntpd nftables --quiet
rc-update add sysklogd default && rc-update add cronie default && rc-update add sshd default && rc-update add ntpd default
emerge -vD sudo zsh tmux dev-vcs/git vim --quiet

# Grub
emerge --quiet grub

# Special things if we are in a KVM Guest
if [ $KVM = true ]; then
echo 'GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0"' >> /etc/default/grub
echo 'GRUB_TERMINAL=console' >> /etc/default/grub
echo "s0:12345:respawn:/sbin/agetty -L 115200 ttyS0 vt100" >> /etc/inittab
grub-install ${HD}
grub-mkconfig -o /boot/grub/grub.cfg
else
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
fi

# Add user
useradd -m -G users,wheel,audio,video -s /bin/zsh $USR
echo $USR:$USRPW | chpasswd

# Exit chroot 
exit

