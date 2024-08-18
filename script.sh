#!/bin/bash

# Awesomewm install script
# install xorg + rec app and shit
sudo apt install -y xorg git unzip feh libpcre3-dev rofi imagemagick acpi bluez blueman xbacklight scrot i3lock nautilus xfce4-power-manager curl tar grep
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
sudo cp -a ~/dotfiles/. ~/.config/

clear
# Reboot
echo "All Done. Reboot now? (y/n)"
read reboot_opt
if [ "$reboot_opt" == "y" ]; then
    sudo reboot
else
    echo "Please reboot later for shit to work"
fi