#!/bin/bash

export disk=/dev/sda
export root_partition=/dev/sda1
export root_password=root
export username=user
export user_password=user
export hostname=arch

echo -e "o\nn\n\n\n\n\nw\n" | fdisk $disk
mkfs.ext4 $root_partition

pacman -Syy
pacman -S reflector --noconfirm
reflector -c "US" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist

mount $root_partition /mnt
pacstrap /mnt base base-devel linux linux-firmware vim git htop networkmanager grub openssh

genfstab -U /mnt >> /mnt/etc/fstab
echo "tmpfs	/home/$username/.cache	tmpfs	noatime,nodev,nosuid	0 0" >> /mnt/etc/fstab

cat <<EOF > /mnt/root/part2.sh
#!/bin/bash
# timedatectl list-timezones
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo $hostname > /etc/hostname
echo -e "${root_password}\n${root_password}" | passwd

grub-install $disk
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable sshd
pacman -Syu --noconfirm
useradd -m $username
usermod -aG wheel $username
echo -e "${user_password}\n${user_password}" | passwd $username
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "alias ls='ls --color=auto'" >> /etc/profile
echo "alias ll='ls -alF'" >> /etc/profile

sudo -H -u $username bash -c "git clone https://aur.archlinux.org/yay.git /tmp/yay;cd /tmp/yay/;makepkg -si --noconfirm;yay -Syu --noconfirm"
exit
EOF

chmod +x /mnt/root/part2.sh
arch-chroot /mnt /root/part2.sh
rm -rf /mnt/root/part2.sh

shutdown -h now

# unplug installer usb
# restart
