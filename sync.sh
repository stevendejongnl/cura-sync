#! /bin/bash

if ! command -v 7z &> /dev/null; then
	echo "7z could not be found"
	exit
fi


add () {
	7z a config $HOME/.config/cura
	7z a share $HOME/.local/share/cura
}


extract () {
	7z e "config.7z" -o "$HOME/.config/cura"
	7z e "share.7z" -o "$HOME/.local/share/cura"
}




read -p "Extract repo files (else add to zip)? (yes/no) " yn
case $yn in
	yes )
		extract
	;;
	no )
		add
	;;
	* )
		echo invalid response
		exit 1
	;;
esac

