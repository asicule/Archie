#!/bin/sh

ssh target "https://raw.githubusercontent.com/lastLunarEclipse/Archie/master/arch-install-uefi.sh > /arch-install-uefi.sh"
ssh target "chmod +x /arch-install-uefi.sh"
