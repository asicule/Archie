#!/bin/sh

ssh target "
rm /boot/grub/themes/custom/*.ttf 2> /dev/null
rm /boot/grub/themes/custom/*.png 2> /dev/null
rm /boot/grub/themes/custom/*.jpg 2> /dev/null
rm /boot/grub/themes/custom/*.svg 2> /dev/null
"

rsync -r ./root/ target:/ 

ssh target "
convert /boot/grub/themes/custom/splash.* -gravity center -crop 16:9 -format png +repage -alpha on /boot/grub/themes/custom/splash.png
grub-mkfont -s 36 -o /boot/grub/fonts/custom.pf2 /boot/grub/themes/custom/*.ttf && \
grub-mkconfig -o /boot/grub/grub.cfg && \
sleep 2 && \
reboot
"