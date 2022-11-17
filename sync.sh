#! /bin/bash

REPODIR=$(dirname "$0")

if [ -z "$2" ]; then 
	COPYDIR="/shared_drives/printing/sync/"
else
	COPYDIR=$2
fi

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
	unlock
}


extract () {
	lock
	7z x "$REPODIR/config.7z" -o"$HOME/.config" | tee "$REPODIR/logs/config-extract.log"
	7z x "$REPODIR/share.7z" -o"$HOME/.local/share" | tee "$REPODIR/logs/share-extract.log"
	unlock
}


copy () {
	if test -f "$REPODIR/.lock"; then
		echo "Sync locked, wait or remove .lock yourself."

		sleep 30s
		copy
	else
		touch "$REPODIR/.lock"
		cp -Rv "$REPODIR/config.7z" "$REPODIR/share.7z" "$COPYDIR" | tee "$REPODIR/logs/copy.log"
		unlock
	fi
}


sync () {
	if test -f "$REPODIR/.lock"; then
		echo "Sync locked, wait or remove .lock yourself."

		sleep 30s
		sync
	else
		touch "$REPODIR/.lock"
		cp -Rv "$COPYDIR/config.7z" "$COPYDIR/share.7z" "$REPODIR" | tee "$REPODIR/logs/copy.log"
		unlock
		extract
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
	copy
	exit 0
fi

if [[ $1 == "sync" ]]; then
	sync
	exit 0
fi

if [[ $1 == "unlock" ]]; then
	unlock
	exit 0
fi


read -p "Archive, Extract or copy? (a/e/c/s) " yn
case $yn in
	e )
		extract
	;;
	a )
		archive
	;;
	c )
		copy
	;;
	s )
		sync
	;;
	* )
		echo invalid response
		exit 1
	;;
esac

