# syncchanges.sh
This is a simple shell script designed to sync the changes between one directory and some others, which is inspired by me keeping copying dotfiles between the config directories and my dotfiles repository on my different machines.

## Description
For every file or directory in the current directory (*NOT recursively*), it will check if the file or directory exists in the source directories. If it does, it will copy the file or directory to the current directory or vice versa. If not, it will simply skip it.

If the file or directory exists in more than one source directory, it will copy the file or directory from the first source directory that contains it.

## Usage
```bash
./syncchanges.sh [push|pushall|pull|pullall]
```

## Source Directories
The default source directories are:
```
/home/user
/home/user/.config
```
Set your source directories in `~/.config/syncchanges.conf` by simply listing them one per line:
```
/home/user/dir1
/home/user/dir2
...
```
Or of course you can just set them in the script itself.
