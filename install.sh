#!/bin/bash

# Awesomewm install script

# install xorg + rec app and shit
sudo apt install -y xorg git unzip feh libpcre3-dev rofi imagemagick acpi bluez blueman alsa-utils xbacklight scrot i3lock nautilus xfce4-power-manager

# install sddm
sudo apt install --no-install-recommends -y sddm

# install awesome
sudo apt install awesome -y

# Dotfiles and shit
## picom-ibhagwan

### Deps
sudo apt install -y libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson ninja-build uthash-dev cmake libxext-dev libxcb-xinerama0-dev

### installation
git clone https://github.com/ibhagwan/picom.git ./picom-ibhagwan
cd picom-ibhagwan
meson setup --buildtype=release build
ninja -C build
sudo ninja -C build install
rm -rf build picom*

## Fonts
mkdir req_font
cd req_font
wget -O req_font.zip "https://www.dropbox.com/scl/fo/3m2hyf95iwp2gl00xqduq/AJ6CGeJEsJ98t-r36LYziTI?rlkey=8mokcdahierso4ly01v1dh5l0&st=ulz6nooe&dl=1"
unzip *.zip
rm -rf *.zip
sudo cp *.{ttf,otf} /usr/local/share/fonts
sudo fc-cache
cd
rm -rf req_font

## Dotfiles
git clone https://github.com/j0hnVu/WillPower3309-awesomewm-dotfiles.git ./dotfiles
sudo cp -a ~/dotfiles/. ~/.config/
cd

clear -x
## Spicetify
printf "\n"
echo "Do you want to install Spicetify? (y/n)"
read spicetify_opt
if [ "$spicetify_opt" == "y" ]; then
    ### Spotify
    sudo mkdir -p /etc/apt/keyrings
    curl -sSf https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/spotify.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update
    sudo apt install -y spotify-client

    ### prompt for username to install spicetify
    echo "Please enter your username: "
    read usrname
    export PATH="$PATH:/home/$usrname/.spicetify"
    ### Spicetify
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh)"
else
    echo "Won't install Spicetify"
fi

clear-x
## oh-my-zsh
print "\n"
echo "Do you want to install oh-my-zsh? (y/n)"
read zsh_opt
if [ "zsh_opt" == "y" ]; then
    echo "Do you want to install powerlevel10's ZSH theme and install some plugins? (y/n)"
    read zsht_opt
    sudo apt install zsh
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    if ["$zsht_opt"== "y"]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
        sudo cp ~/.zshrc ~/zshrc.bak
        sudo sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
        sudo sed -i 's/^plugins=(git)$/plugin=(git, zsh-syntax-highlighting, zsh-autosuggestions)/' "$HOME/.zshrc"
else
    echo "Won't install ZSH"
fi

clear -x

# Reboot
echo "All Done. Reboot now? (y/n)"
read reboot_opt
if ["$reboot_opt" == "y"]; then
    sudo reboot
else
    echo "Please reboot later for shit to work"
fi









