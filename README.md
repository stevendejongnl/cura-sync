# Cura Sync (Backup)

A bash script for syncing my [Ultimaker Cura](https://ultimaker.com/en/software/ultimaker-cura) config/profiles between linux machines.

This script creates or extract a compressed file for `~/.local/share/cura` and `~/.config/cura`.


## How to use

Run the script, the script will ask for archiving or extracting.
```bash
./sync.sh
```


### Archive

```bash
./sync.sh archive
```


### Extract

```bash
./sync.sh archive
```


## Automate

I use [Incron](https://wiki.archlinux.org/title/Incron) for automating this process.

In my crontab I check for changes in the cura directories to archive them.
When there are new archives I copy them to my shared drive.
And last when there are new archives (from my other machines) in my shared drive I extract them to my cura directories.
```bash
# Check cura file changes and archive
/home/my_user/.config/cura	IN_CREATE,IN_DELETE,IN_CLOSE_WRITE	/home/my_user/cura-sync/sync.sh archive
/home/my_user/.local/share/cura	IN_CREATE,IN_DELETE,IN_CLOSE_WRITE	/home/my_user/cura-sync/sync.sh archive

# Copy cura archived files to shared directory
/home/my_user/cura-sync	IN_CREATE,IN_DELETE,IN_CLOSE_WRITE	/home/my_user/cura-sync/sync.sh copy /home/my_user/cura-sync/config.7z /home/my_user/cura-sync/share.7z /shared_drives/printing/sync/

# Extract cura files from shared drive
/shared_drives/printing/sync	IN_CREATE,IN_DELETE,IN_CLOSE_WRITE	/home/my_user/cura-sync/sync.sh copy /shared_drives/printing/sync/config.7z /shared_drives/printing/sync/share.7z /home/my_user/cura-sync/ && /home/my_user/cura-sync/sync.sh extract
```