#!/bin/bash
#SHELL SCRIPT FOR EASIER FFMPEG 
#This script is compatible with ffeasy and is
# a FOLDER LOOP
#/home/adam/.bin/ffall

#USAGE: ffall MODE FOLDER                (omit slash after folder)
#Eg.    ffall android /home/user/Desktop (Converts all on desktop using android function in ffeasy)

#so that parameters passed to program can be kept through functions
arg1="$1"
arg2="$2"
arg3="$3"
arg4="$4"
arg5="$5"

mode="Dir"
echo mode set to $mode

echo -ne "\033]0;BUSY $promptInput mode:$mode\007"

for f in $1/*.*
do
    ffeasy $2 "$f" "${f%.*}$mode.${f#*.}"
done

