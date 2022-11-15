#! /bin/bash

REPODIR=$(dirname "$0")

if ! command -v 7z &> /dev/null; then
	echo "7z could not be found"
	exit
fi


lock () {
	if test -f "$REPODIR/.lock"; then
		echo "Sync locked, wait or remove .lock yourself."
		exit 0
	fi

	touch "$REPODIR/.lock"
}


unlock () {
	rm "$REPODIR/.lock"
}


archive () {
	lock
	7z a config "$HOME/.config/cura" -w"$REPODIR" -xr@$REPODIR/exclude.lst
	7z a share "$HOME/.local/share/cura" -w"$REPODIR" -xr@$REPODIR/exclude.lst
	unlock
}


extract () {
	lock
	7z x "$REPODIR/config.7z" -o"$HOME/.config"
	7z x "$REPODIR/share.7z" -o"$HOME/.local/share"
	unlock
}


if [[ $1 == "archive" ]]; then
	archive
	exit 0
fi

if [[ $1 == "extract" ]]; then
	extract
	exit 0
fi


read -p "Archive or Extract? (a/e) " yn
case $yn in
	e )
		extract
	;;
	a )
		archive
	;;
	* )
		echo invalid response
		exit 1
	;;
esac

