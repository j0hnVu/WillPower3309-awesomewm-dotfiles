#!/bin/bash

# Awesomewm & X11 install script on Debian 12 Minimal Install
# Need function that handle user input (yn and shit) (idk?)

# for Minimal Install shit only
## install minimal xorg
sudo apt install -y xserver-xorg-video-intel xserver-xorg-core xinit

## install sddm
sudo apt install --no-install-recommends -y sddm

# install awesomewm
sudo apt install awesome awesome-extra -y

# WillPower3309-awesomewm-dotfiles

## Rec app and shit
sudo apt install -y git unzip feh libpcre3-dev rofi imagemagick acpi bluez blueman xbacklight scrot i3lock nautilus xfce4-power-manager curl tar grep gpg sed


## picom-ibhagwan
### Deps
sudo apt install -y libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson ninja-build uthash-dev cmake libxext-dev libxcb-xinerama0-dev
### installation
git clone https://github.com/ibhagwan/picom.git ./picom-ibhagwan
cd picom-ibhagwan
meson setup --buildtype=release build
ninja -C build
sudo ninja -C build install

## Global Fonts
mkdir req_font
cd req_font
wget -O req_font.zip "https://www.dropbox.com/scl/fo/3m2hyf95iwp2gl00xqduq/AJ6CGeJEsJ98t-r36LYziTI?rlkey=8mokcdahierso4ly01v1dh5l0&st=ulz6nooe&dl=1"
unzip *.zip
sudo cp *.{ttf,otf} /usr/local/share/fonts
sudo fc-cache
cd


## Dotfiles assets
sudo cp -a ~/dotfiles/. ~/.config/

## oh-my-zsh
clear
echo "Do you want to install oh-my-zsh and KittyTerminal? (y/n)"
read zsh_opt
if [ "$zsh_opt" == "y" ]; then
    echo "Do you want to install powerlevel10's ZSH theme and install some plugins? (y/n)"
    read zsht_opt
	sudo apt install -y kitty	
    sudo apt install -y zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    if [ "$zsht_opt" == "y" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
		git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        sudo cp ~/.zshrc ~/zshrc.bak
        sudo sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
        sudo sed -i 's/^plugins=(git)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' "$HOME/.zshrc"
		chsh -s $(which zsh)
    fi
else
    echo "Won't install ZSH"
fi

## Spicetify
printf "\n"
echo "Do you want to install Spicetify? (y/n)"
read spicetify_opt
    if [ "$spicetify_opt" == "y" ]; then
        ### Spotify
        sudo mkdir -p /etc/apt/keyrings
        curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
		echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
        sudo apt update
        sudo apt install -y spotify-client
        ### prompt for username to install spicetify
        export PATH="$PATH:/home/$USER/.spicetify"
        ### Spicetify
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh)"
    else
        echo "Won't install Spicetify"
    fi

## Cleanning up
clear
echo "Cleanning up..."
cd
rm -rf req_font/ build/ picom*/ dotfiles/


# NVIDIA driver
## proprietary driver install
clear
if lspci -nn | grep -iE 'vga.*nvidia'; then
	echo "Do you want to install proprietary NVIDIA driver? (y,n)"
	read nvidia_opt
	if $nvidia_opt == "y"; then
		sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
		echo "## for nvidia" | sudo tee -a /etc/apt/sources.list
		echo "deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list
		sudo apt update
		sudo apt install -y linux-headers-amd64 nvidia-driver firmware-misc-nonfree
		rm -rf /etc/apt/sources.list
		sudo cp /etc/apt/sources.list.backup /etc/apt/sources.list
	else
		echo "Continue..." && sleep 1
	fi
else	
	echo "Nvidia GPU not found. Continue..." && sleep 1
fi

## Secure Boot for NVIDIA driver (Optional)
clear
if sudo mokutil --sb-state | grep -q "enabled"; then
    if [ ! -d /var/lib/shim-signed/mok/ ]; then
		sudo mkdir -p /var/lib/shim-signed/mok/
		cd /var/lib/shim-signed/mok/
		sudo openssl req -nodes -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -days 36500 -subj "/CN=My Name/"
		sudo openssl x509 -inform der -in MOK.der -out MOK.pem
		echo "You will be prompt for one-time password." && sleep 1
		sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
		sudo touch /etc/dkms/framework.conf
		echo "mok_signing_key="/var/lib/shim-signed/mok/MOK.priv"" | sudo tee -a /etc/dkms/framework.conf
		echo "mok_certificate="/var/lib/shim-signed/mok/MOK.der"" | sudo tee -a /etc/dkms/framework.conf
		echo "sign_tool="/etc/dkms/sign_helper.sh"" | sudo tee -a /etc/dkms/framework.conf
		echo "/lib/modules/"$1"/build/scripts/sign-file sha512 /root/.mok/client.priv /root/.mok/client.der "$2"" | sudo tee -a /etc/dkms/sign_helper.sh
		VERSION="$(uname -r)"
		SHORT_VERSION="$(uname -r | cut -d . -f 1-2)"
		MODULES_DIR=/lib/modules/$VERSION
		KBUILD_DIR=/usr/lib/linux-kbuild-$SHORT_VERSION
		cd "$MODULES_DIR/updates/dkms"
		echo -n "Passphrase for the private key: "
		read -s KBUILD_SIGN_PIN
		export KBUILD_SIGN_PIN
		find -name \*.ko | while read i; do sudo --preserve-env=KBUILD_SIGN_PIN "$KBUILD_DIR"/scripts/sign-file sha256 /var/lib/shim-signed/mok/MOK.priv /var/lib/shim-signed/mok/MOK.der "$i" || break; done
		sudo update-initramfs -k all -u
		sudo mokutil --import /var/lib/dkms/mok.pub
	fi
else
	echo "Secure Boot is disabled. Continue" && sleep 1
fi

# Reboot
echo "All Done. Reboot now? (y/n)"
read reboot_opt
if [ "$reboot_opt" == "y" ]; then
    sudo reboot
else
    echo "Please reboot later"
fi