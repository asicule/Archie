#!/bin/sh

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root"
   exit 1
fi

echo "Downloading package list..."
curl -s https://raw.githubusercontent.com/lastLunarEclipse/Archie/packageList > packageList

echo "Do you want to configure package list? (y/n)"
read answer
if [ "$answer" = "y" ]; then
    vim packageList
fi

clear
echo "Unmounting partitions..."
swapoff -a
umount -R /mnt
echo "###############################################################################"
loadkeys us && \
timedatectl set-ntp true && \
timedatectl status && \
echo "###############################################################################"
ping archlinux.org -c 5 || exit 1
echo "###############################################################################"
lsblk && \
echo "-------------------------------------------------------------------------------"

echo "Please select the disk to install Arch Linux on:" && \
read DEV && \
fdisk -l /dev/$DEV

echo "-------------------------------------------------------------------------------"
echo "Please enter swap partition size in GB:" && \
read SWAP_SIZE && \

echo "-------------------------------------------------------------------------------"
echo "Partitioning /dev/$DEV" && \
parted /dev/$DEV mklabel gpt && \
echo "Creating boot partition" && \
parted /dev/$DEV mkpart ESP 1MiB 512MiB && \
echo "Creating swap partition" && \
parted /dev/$DEV mkpart primary linux-swap 512MiB $SWAP_SIZE"GiB" && \
echo "Creating root partition" && \
parted /dev/$DEV mkpart primary ext4 $SWAP_SIZE.5GiB 100% && \

mkfs.fat -F32 /dev/$DEV"1" && \
mkswap /dev/$DEV"2" && \
mkfs.ext4 /dev/$DEV"3" && \

echo "-------------------------------------------------------------------------------"
lsblk

echo "###############################################################################"
echo "Mounting partitions" && \
mount /dev/$DEV"3" /mnt && \
mkdir /mnt/boot && \
mount /dev/$DEV"1" /mnt/boot && \
swapon /dev/$DEV"2"
echo "###############################################################################"

grep -v -E '^#|^\[' packageList | pacstrap /mnt
echo "###############################################################################"

echo "Generating fstab" && \
genfstab -U /mnt >> /mnt/etc/fstab && \

echo "###############################################################################"
echo "Downloading Arch Linux chroot script" && \
cp arch-mid-install.sh /mnt/arch-mid-install.sh && \
chmod +x /mnt/arch-mid-install.sh && \

echo "###############################################################################" && \
echo "Changing root" && \
echo "Please run arch-mid-install.sh in chroot" && \

arch-chroot /mnt || exit 1

swapoff -a && \
umount /mnt/boot && \
umount /mnt && \

echo "Do you want to reboot now?" && \
read REBOOT
if [ "$REBOOT" = "y" ]; then
    echo "###############################################################################"
    echo "Rebooting... please remove the installation medium"
    sleep 5
    reboot
fi