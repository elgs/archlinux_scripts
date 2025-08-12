# Arch Linux Scripts

## install_archlinux.sh

This script will help to automate the installation of Arch Linux. Please note the purpose of this script is to reduce typing on the keyboard. This is not a general purpose Arch Linux installer. So please feel free to tweak it as you need if you find it helpful.

### Before you start

## !!!PLEASE NOTE THIS SCRIPT WILL WIPE OUT ALL DATA ON YOUR HARD DRIVE, SO DO IT AT YOUR OWN RISK!!!

### Where it starts

`install_archlinux_uefi.sh` and `install_archlinux_bios` have the following assumptions:

1. UEFI;
2. booted into the latest iso image downloaded from Arch Linux website;
3. an empty disk without any partitions;
4. Internet connection;

I found it easier to do the job by runing this script from an ssh client. After booted from the Arch Linux iso:

```bash
# systemctl start sshd
# passwd
# ip a
```

Setup Wi-Fi with `iwctl`.

```bash
# iwctl
[iwd]# station wlan0 connect SSID
```
or 
```bash
[iwd]# station name connect-hidden SSID
```
https://wiki.archlinux.org/title/Iwd

1. start sshd;
2. set root password;
3. get the ip address so you can ssh in from another computer where it's easier for you to edit this script;

### What it does

#### environment variables you may want to set

```bash
export disk=/dev/sda
export boot_partition=/dev/sda1
export root_partition=/dev/sda2
export root_password=root
export username=user
export user_password=user
export hostname=arch
```

#### disk partitioning

1GB for `/boot`, and the rest for `/`. If you don't like this idea, just tweak this line, or remove this line and do the partitioning yourself at all.

```bash
echo -e "g\nn\n\n\n+1G\nn\n\n\n\nt\n1\n1\np\nw\nq\n" | fdisk $disk
```

#### mounting user cache dir to ram disk

It mounts `/home/$username/.cache` to ram disk so browser cache won't hit the ssd. If you don't like this idea, remove this line:

```bash
echo "tmpfs	/home/$username/.cache	tmpfs	noatime,nodev,nosuid	0	0" >> /mnt/etc/
fstab
```

#### yay

It installs yay.

### Where it ends

This script will shutdown your computer after it's done. Once it's shutdown, you should unplug the Arch Linux installation iso and restart your computer. You should be able to login with either root or your username.

### Next steps

This is the end of the installation of Arch Linux, but the start of the setup. Next things you want to do might be to install a desktop environment, which is not covered in this script.

### Setup NetworkManager for Wi-Fi

```bash
nmcli device wifi connect SSID_or_BSSID --ask
```

https://wiki.archlinux.org/title/NetworkManager
https://askubuntu.com/questions/947965/how-to-trigger-network-manager-autoconnect
