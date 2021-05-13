
HNAME="hopper"
sudo hostnamectl set-hostname $HNAME
sudo nano /etc/hosts

sudo visudo
# add Defaults env_reset,timestamp_timeout=90
