## Secure Boot (Optional)
clear
if sudo mokutil --sb-state | grep -q "enabled"; then
    if [ ! -d /var/lib/shim-signed/mok/ ]; then
		sudo mkdir -p /var/lib/shim-signed/mok/
		cd /var/lib/shim-signed/mok/
		sudo openssl req -nodes -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -days 36500 -subj "/CN=My Name/"
		sudo openssl x509 -inform der -in MOK.der -out MOK.pem
		echo "You will be prompt for one-time password." && sleep 1
		sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
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