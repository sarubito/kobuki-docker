#!/bin/bash

FILE="test.txt"

if [ -e $FILE ]; then
	echo "File exits."
else
	echo "File doesn't exits"
fi

