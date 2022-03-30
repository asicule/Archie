#!/bin/sh

echo "###############################################################################" && \
nmcli device rescan && \
sleep 4 && \
nmcli device wifi list && \
echo "###############################################################################" && \
echo "Please enter wifi SSID: " && \
read SSID && \
echo "Please enter wifi password: " && \
read PASSWORD && \
nmcli device wifi connect $SSID password $PASSWORD