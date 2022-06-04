#!/bin/sh

echo "###############################################################################"
sleep 1

pacman -Syyu
echo "What editor do you want to use [nano/vim/etc.]"
read EDITOR

echo "Setting up locale"
$EDITOR /etc/locale.gen || exit 1

ls /usr/share/zoneinfo | less || exit 1
echo "Please enter your region timezone:"
read REGION_TIMEZONE

ls /usr/share/zoneinfo/$REGION_TIMEZONE | less || exit 1
echo "Please enter your timezone: "
read TIMEZONE

echo "Setting up timezone"
ln -sf /usr/share/zoneinfo/$REGION_TIMEZONE/ /etc/localtime || exit 1
locale-gen || exit 1

echo "Syncing clock"
hwclock --systohc || exit 1

echo "###############################################################################"
echo "LANG=en_US.UTF-8" > /etc/locale.conf || exit 1
echo "KEYMAP=us" > /etc/vconsole.conf || exit 1

echo "Please enter your hostname:"
read HOSTNAME
echo "Setting hostname to $HOSTNAME"
echo "$HOSTNAME" > /etc/hostname || exit 1

echo "Setting root password"
passwd || exit 1

echo "Please enter your username:"
read USERNAME
echo "Setting username to $USERNAME"
useradd -m -G wheel -s /bin/zsh --badnames $USERNAME || exit 1

echo "Please enter $USERNAME password:"
passwd $USERNAME || exit 1

echo "--------------------------------------------------------------------------------"
echo "Configuring sudo"
echo "" >> /etc/sudoers || exit 1
echo "# Allow user to run all commands without asking password" >> /etc/sudoers || exit 1
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers || exit 1
echo "--------------------------------------------------------------------------------"

echo "Installing grub for UEFI system"
pacman -S --needed --noconfirm grub efibootmgr || exit 1
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub || exit 1
grub-mkconfig -o /boot/grub/grub.cfg

echo "Do you want to enable wireless services?[y/n] "
read ENABLE_WIRELESS_SERVICES
if [ $ENABLE_WIRELESS_SERVICES == 'y' ]; do
    pacman -S --needed network-manager wpa_supplicant bluez acpid
    echo "Enabling services"
    systemctl enable NetworkManager.service
    systemctl enable wpa_supplicant.service
    systemctl enable bluetooth.service
    systemctl enable acpid.service
done