#!/bin/sh

echo "###############################################################################" && \
sleep 1 && \

echo "What editor do you want to use [nano/vim/etc.]" && \
read EDITOR && \

echo "Setting up locale" && \
$EDITOR /etc/locale.gen && \

ls /usr/share/zoneinfo | less && \
echo "Please enter your region timezone:" && \
read REGION_TIMEZONE && \

ls /usr/share/zoneinfo/$REGION_TIMEZONE | less && \
echo "Please enter your timezone: " && \
read TIMEZONE && \

echo "Setting up timezone" && \
ln -sf /usr/share/zoneinfo/$REGION_TIMEZONE/ /etc/localtime && \
locale-gen && \

echo "Syncing clock" && \
hwclock --systohc && \

echo "###############################################################################" && \
echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
echo "KEYMAP=us" > /etc/vconsole.conf && \

echo "Please enter your hostname:" && \
read HOSTNAME && \
echo "Setting hostname to $HOSTNAME" && \
echo "$HOSTNAME" > /etc/hostname && \

echo "Setting root password" && \
passwd || exit 1

echo "Please enter your username:" && \
read USERNAME && \
echo "Setting username to $USERNAME" && \
useradd -m -G wheel -s /bin/zsh --badnames $USERNAME && \

echo "Please enter $USERNAME password:" && \
passwd $USERNAME && \

echo "--------------------------------------------------------------------------------" && \
echo "Configuring sudo" && \
echo "" >> /etc/sudoers && \
echo "# Allow user to run all commands without asking password" >> /etc/sudoers && \
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
echo "--------------------------------------------------------------------------------" && \

echo "Installing grub for UEFI system" && \
pacman -Syu --noconfirm grub efibootmgr && \
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub && \
grub-mkconfig -o /boot/grub/grub.cfg

echo "Do you want to enable some services?[y/n] " && \
read ENABLE_SERVICES
if [ $ENABLE_SERVICES == 'y' ]; do
    echo "Enabling services" && \
    systemctl enable NetworkManager.service && \
    systemctl enable wpa_supplicant.service && \
    systemctl enable sshd.service && \
    systemctl enable bluetooth.service && \
    systemctl enable acpid.service
done