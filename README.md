# Use at your own risk [UEFI ONLY]
**User target for this repo is remote install**

use vim as text editor on install
[[vim cheat sheet](https://github.com/gibbok/vim-cheat-sheet)]

Put background image as [splash.png](./root/boot/grub/themes/custom)

`curl https://raw.githubusercontent.com/lastLunarEclipse/Archie/master/arch-install-uefi.sh > arch-install-uefi.sh && sh ./arch-install-uefi.sh`
# File-Manual
## Installer
[arch-install-uefi](./arch-install-uefi.sh)
   - main installer
   - semi-auto partitioning
      - /dev/sdx1 as /boot 511MB [FAT32]
      - /dev/sdx2 as swap user-defined size (GB) [SWAP]
      - /dev/sdx3 as / remaining [ext4]
   - use with [arch-mid-install](./arch-mid-install.sh)
   - **Auto loadkey us** changed this on line 22 of [this file](./arch-install-uefi.sh)
   - install pacman package that listed in [packageList](./packageList)
   - generate fstab
   - change chroot to /mnt
   - ask user to execute [arch-mid-install](./arch-mid-install.sh)
   - setup locale
   - ask user to specified timezone
   - sync hardware clock
   - set LANG=en_US.UTF-8 to /etc/locale.conf
   - set KEYMAP=us to /etc/vconsole.conf
   - ask user for hostname, rootpassword, username, and userpassword
   - configure sudo > bypass password, so reconfigure yourself 
   - install grub & efibootmgr
   - make grub config
   - enable services include
      - NetworkManager
      - wpa_supplicant
      - sshd
      - bluetooth
# LICENSE
`All file that aren't list below is under MIT License`
### Third party
All files under root/boot/grub/theme/custom are from [AdisonCavani/distro-grub-themes](https://github.com/AdisonCavani/distro-grub-themes) excluding
 - [arch-blue (CC-BY-SA 3.0)](https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Archlinux-icon-crystal-64.svg/240px-Archlinux-icon-crystal-64.svg.png)