#!/bin/sh

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root"
   exit 1
fi

clear
echo "Unmounting partitions..."
swapoff -a
umount -R /mnt
echo "###############################################################################"
loadkeys us || exit 1
timedatectl set-ntp true
timedatectl status || exit 1
echo "###############################################################################"
ping archlinux.org -c 5 || exit 1
echo "###############################################################################"
lsblk || exit 1
echo "-------------------------------------------------------------------------------"

echo "Please select the disk to install Arch Linux on:"
read sdx || exit 1
fdisk -l /dev/$sdx || exit 1

echo "-------------------------------------------------------------------------------"
echo "Please enter swap partition size in GB:"
read SWAP_SIZE || exit 1

echo "-------------------------------------------------------------------------------"
echo "Partitioning /dev/$sdx"
parted /dev/$sdx mklabel gpt || exit 1
echo "Creating boot partition"
parted /dev/$sdx mkpart ESP 1MiB 512MiB || exit 1
echo "Creating swap partition"
parted /dev/$sdx mkpart primary linux-swap 512MiB $SWAP_SIZE"GiB" || exit 1
echo "Creating root partition"
yes | parted /dev/$sdx mkpart primary ext4 $SWAP_SIZE.5GiB 100% || exit 1

mkfs.fat -F32 /dev/$sdx"1" || exit 1
mkswap /dev/$sdx"2" || exit 1
mkfs.ext4 /dev/$sdx"3" || exit 1

echo "-------------------------------------------------------------------------------"
lsblk

echo "###############################################################################"
echo "Mounting partitions"
mount /dev/$sdx"3" /mnt || exit 1
mkdir /mnt/boot || exit 1
mount /dev/$sdx"1" /mnt/boot || exit 1
swapon /dev/$sdx"2" || exit 1
echo "###############################################################################"
echo "Please enter packages that you want to install"
read packageList || exit 1
echo "Do you want to include recommanded package? [y/n]"
read include_recommand || exit 1
if [ "$include_recommand" = "y" ]; then
    packageList="linux base git less vim sudo man-db networkmanager wpa_supplicant bluez zsh $packageList"
fi
pacstrap /mnt $packageList || exit 1

echo "###############################################################################"

echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab || exit 1

echo "###############################################################################"
cp arch-mid-install.sh /mnt/arch-mid-install.sh && \
chmod +x /mnt/arch-mid-install.sh && \
echo "Please run arch-mid-install.sh in chroot"

echo "Changing root"
arch-chroot /mnt || exit 1

swapoff -a || exit 1
umount /mnt/boot || exit 1
umount /mnt || exit 1

echo "Do you want to reboot now?"
read REBOOT || exit 1
if [ "$REBOOT" = "y" ]; then
    echo "###############################################################################"
    echo "Rebooting... please remove the installation medium"
    sleep 5
    reboot || exit 0
fi
