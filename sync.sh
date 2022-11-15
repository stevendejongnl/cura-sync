#! /bin/bash

if ! command -v 7z &> /dev/null; then
	echo "7z could not be found"
	exit
fi


archive () {
	7z a config "$HOME/.config/cura" -xr@exclude.lst
	7z a share "$HOME/.local/share/cura" -xr@exclude.lst
}


extract () {
	7z x "config.7z" -o"$HOME/.config"
	7z x "share.7z" -o"$HOME/.local/share"
}




read -p "Extract or Archive? (extract/archive) " yn
case $yn in
	extract )
		extract
	;;
	archive )
		archive
	;;
	* )
		echo invalid response
		exit 1
	;;
esac

