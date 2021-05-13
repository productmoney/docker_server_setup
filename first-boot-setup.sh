export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y

apt-get install apt-utils
apt-get install software-properties-common
apt-get install -y htop wget git ntp zsh apt-transport-https ca-certificates curl rsync

password_length=12
randompw=$(date +%s | sha256sum | base64 | head -c "$password_length" ; echo)

echo ""
echo "----------"
echo "Please enter your desired user name"
read -r DESIRED_USERNAME

adduser -m -p "$randompw" -s /bin/bash "$DESIRED_USERNAME"
echo "Added $DESIRED_USERNAME with the randomized password:"
echo "$randompw"

adduser "$DESIRED_USERNAME" sudo

#echo ""
#echo "----------"
#echo "Please enter your desired hosts name"
#read -r HNAME
#
#sudo hostnamectl set-hostname $HNAME
#sudo nano /etc/hosts

echo ""
echo "----------"
echo "Done, please re-login as user account now."

exit 1
