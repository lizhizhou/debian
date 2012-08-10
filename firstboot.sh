passwd
/debootstrap/deboostrap --second-stage
apt-get update
dpkg --set-selections < /dpkg-get-selections
apt-get -u dselect-upgrade
