#!/bin/sh

echo "setting up ssh..."
# generate ed25519 key
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "" -f ~/.ssh/id_ed25519
fi
# setup ssh server
if [ ! -f ~/.ssh/authorized_keys ]; then
    cp ~/.ssh/id_ed25519.pub ~/.ssh/authorized_keys
fi
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_ed25519

# disable password authentication
if [ ! -f /etc/ssh/sshd_config ]; then
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
fi
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

