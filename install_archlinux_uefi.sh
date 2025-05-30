#!/bin/bash

export disk=/dev/nvme0n1
export boot_partition=/dev/nvme0n1p1
export root_partition=/dev/nvme0n1p2
export root_password=root
export username=user
export user_password=user
export hostname=arch

# /boot 1GB
# / rest
echo -e "g\nn\n\n\n+1G\nn\n\n\n\nt\n1\n1\nw\n" | fdisk $disk
mkfs.fat -F32 $boot_partition
mkfs.ext4 $root_partition

pacman -Syy
pacman -S reflector --noconfirm
reflector -c "US" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist

mount $root_partition /mnt
pacstrap /mnt base base-devel linux linux-firmware vim git htop networkmanager grub efibootmgr openssh

genfstab -U /mnt >> /mnt/etc/fstab
echo "tmpfs	/home/$username/.cache	tmpfs	noatime,nodev,nosuid	0 0" >> /mnt/etc/fstab

cat <<EOF > /mnt/root/part2.sh
#!/bin/bash
timedatectl set-timezone America/Los_Angeles
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo $hostname > /etc/hostname
echo -e "${root_password}\n${root_password}" | passwd

mkdir /boot/efi
mount $boot_partition /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
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
