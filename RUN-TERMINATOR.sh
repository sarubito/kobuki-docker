#!/bin/bash
xhost +
if [ -e "$HOME/.config/terminator/config_bk" ]; then
	echo "File exists."
	cp -f $PWD/config $HOME/.config/terminator/config
else
	echo "File doesn't exists."
	cp -f $HOME/.config/terminator/config $HOME/.config/terminator/config_bk
	echo "make config_bk"
	cp -f $PWD/config $HOME/.config/terminator/config
fi

terminator -l kobuki


