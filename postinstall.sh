#!/bin/bash
# Post-installation

clear
# oh-my-zsh
echo "Do you want to install oh-my-zsh? (y/n)"
read zsh_opt
if [ "$zsh_opt" == "y" ]; then
    echo "Do you want to install powerlevel10's ZSH theme and install some plugins? (y/n)"
    read zsht_opt
    sudo apt install -y zsh
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    if [ "$zsht_opt"== "y" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
        sudo cp ~/.zshrc ~/zshrc.bak
        sudo sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
        sudo sed -i 's/^plugins=(git)$/plugins=(git, zsh-syntax-highlighting, zsh-autosuggestions)/' "$HOME/.zshrc"
    fi
else
    echo "Won't install ZSH"
fi

# Spicetify
printf "\n"
echo "Do you want to install Spicetify? (y/n)"
read spicetify_opt
echo "Please login into Spotify first. If u r done, y pls"
read sptf_login
if [ "$sptf_login" == "y" ]; then
    if [ "$spicetify_opt" == "y" ]; then
        ### Spotify
        sudo mkdir -p /etc/apt/keyrings
        curl -sSf https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/spotify.gpg > /dev/null
        echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
        sudo apt update
        sudo apt install -y spotify-client

        ### prompt for username to install spicetify
        export PATH="$PATH:/home/$USER/.spicetify"
        ### Spicetify
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh)"
    else
        echo "Won't install Spicetify"
    fi
else
    echo "Abort."
fi