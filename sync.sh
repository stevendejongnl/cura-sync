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
	rm "$REPODIR/config.7z" "$REPODIR/share.7z"
	7z a config "$HOME/.config/cura" -w"$REPODIR" -xr@$REPODIR/exclude.lst | tee "$REPODIR/logs/config-archive.log"
	7z a share "$HOME/.local/share/cura" -w"$REPODIR" -xr@$REPODIR/exclude.lst | tee "$REPODIR/logs/share-archive.log"
	sleep 1h
	unlock
}


extract () {
	lock
	7z x "$REPODIR/config.7z" -o"$HOME/.config" | tee "$REPODIR/logs/config-extract.log"
	7z x "$REPODIR/share.7z" -o"$HOME/.local/share" | tee "$REPODIR/logs/share-extract.log"
	sleep 1h
	unlock
}


copy () {
	if test -f "$REPODIR/.lock"; then
		echo "Sync locked, wait or remove .lock yourself."

		sleep 30s
		copy "$1" "$2" "$3"
	else
		touch "$REPODIR/.lock"
		cp -Rv "$1" "$2" "$3" | tee "$REPODIR/logs/copy.log"
		unlock
	fi
}


if [[ $1 == "archive" ]]; then
	archive
	exit 0
fi

if [[ $1 == "extract" ]]; then
	extract
	exit 0
fi

if [[ $1 == "copy" ]]; then
	copy "$2" "$3" "$4"
	exit 0
fi

if [[ $1 == "unlock" ]]; then
	unlock
	exit 0
fi


read -p "Archive, Extract or copy? (a/e/c) " yn
case $yn in
	e )
		extract
	;;
	a )
		archive
	;;
	a )
		copy "$1" "$2" "$3"
	;;
	* )
		echo invalid response
		exit 1
	;;
esac

