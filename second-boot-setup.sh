# Run already logged into user account

mkdir -p ~/server_mounts ~/download ~/tmp ~/src ~/work

ssh-keygen -t rsa -b 4096 -C "andrew@product.money"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub

echo "StrictHostKeyChecking no " > ~/.ssh/config
git config --global http.postBuffer 1048576000
echo "[url \"https://${GH_AUTH_TOKEN}:@github.com/\"]\n\tinsteadOf = https://github.com/"
echo "[url \"https://${GH_AUTH_TOKEN}:@github.com/\"]\n\tinsteadOf = https://github.com/" >> ~/.gitconfig

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cd ~/work
git clone "git@github.com:productmoney/dirgeable-setup.git"
cd dirgeable-setup
cp .zsh* ~
cp .gitconfig ~
cp -r oh-my-zsh-stuff/plugins/* ~/.oh-my-zsh/plugins
cp -r oh-my-zsh-stuff/themes/* ~/.oh-my-zsh/themes

echo "Done, please re-login now."
