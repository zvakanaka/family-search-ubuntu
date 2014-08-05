#!/bin/bash
#SHELL SCRIPT FOR EASIER FFMPEG

#MASTER COPY TO BE ON ASUS 
#/home/adam/.bin/ffeasy

#GLOBAL VARIABLES
#-q value (quality)
INSTALLPATH="/home/$USER/.bin/ffeasies"
#so that parameters passed to program can be kept
arg1="$1"
arg2="$2"
arg3="$3"
arg4="$4"
arg5="$5"

#default settings, specific modes may change or ignore them
declare -i QUAL=5
declare -i WIDTH=720
declare -i HEIGHT=480
declare -i FPS=23
#AUDIO BITRATE
ABR="128000"
# FUNCTIONS

#take input and case check
check_input () {

    case $1 in
        "android")
            android
            ;;
        a*)
            android
            ;;
        "vars")
            display_vars
            ;;
        "ipod")
            Message="$1 function has yet to be built"
            ;;
        "play")
            play
            ;;
        "simple")
            simple
            ;;
        rem*)
            remSeg
            ;;
        rotat*)
            rotate
            ;;
        "tunaviDS")
            tunaviDS
            ;;
        tuna*)
            tunaviDS
            ;;
        water*)
            watermark
            ;;
        tag*)
            tagDirectory
            ;;
        "")
            cat $INSTALLPATH/options.txt
            ;;
        *)
            #quick hack, fix later
            play1
            #add-IF one param, PLAY that one param  
            #Message="Is this guy speaking English?"
            ;;
    esac

    echo $Message

    if [ -z "$arg1" ]
    then
        prompt_input
        check_input
    fi
}

#prompt user what to do
prompt_input () {
    #new string
    local promptInput=""
    #user input to string
    read -p "type something to do something:" promptInput
    arg1="$promptInput"
}

#convert for android
android () {
    local WIDTH=800
    local HEIGHT=480
    local VBR="500k"
    local mode="ANDROID"
    echo mode set to $mode
    #new string
    local promptInput=""
    #user input to string
    #read -p "Output file:" promptInput

    #setting title
    echo -ne "\033]0;BUSY $promptInput mode:$mode\007"

    ffmpeg -i $arg2 $arg4 -vcodec libx264 -profile:v high -preset fast -b:v $VBR -maxrate $VBR -bufsize 1000k -vf scale=$WIDTH:-1 -threads 0 -acodec aac -strict experimental -b:a $ABR -ac 2 -ab 44100 $arg3

    echo -ne "\033]0;DONE $promptInput last mode:$mode\007"
}

#convert for simple
simple () {
    local WIDTH=320
    local HEIGHT=240

    #new string
    local promptInput=""
    local mode="SIMPLE"
    echo mode set to $mode

    #setting title
    echo -ne "\033]0;BUSY $promptInput mode:$mode\007"

    ffmpeg -i $arg2 $arg4 -vcodec libx264 -profile:v high -preset medium -b:v 500k -maxrate 500k -bufsize 1000k -vf scale=$WIDTH:-1 -threads 0 -acodec mp3 -strict experimental -b:a $ABR -ac 1 -ab 44100 $arg3

    echo -ne "\033]0;DONE $promptInput last mode:$mode\007"
}

#Removes segment from video and merges into out
#$arg2=INFILE $arg3=OUTFILE $arg4=START $arg5=FINISH
remSeg() {
    local mode="remSeg"
    echo mode set to $mode

    #save the around into temps
    ffmpeg -i $arg2 -y -t $arg4 -avoid_negative_ts 1 -c copy -map 0 TEMP1.mp4
    ffmpeg -i $arg2 -y -ss $arg5 -avoid_negative_ts 1 -c copy -map 0 TEMP2.mp4
    echo "#2 files being merged to $arg3"
    echo "file 'TEMP1.mp4'" > TEMP.txt
    echo "file 'TEMP2.mp4'" >> TEMP.txt
    #merge them back
    ffmpeg -y -f concat -i TEMP.txt -c copy $arg3 
    rm TEMP.txt TEMP1.mp4 TEMP2.mp4

    echo -ne "\033]0;DONE $arg2 last mode:$mode\007"
}

#ROTATE clockwise for the moment
rotate() {
    local promptInput=""
    local mode="ROTATE"
    echo mode set to $mode
    echo -ne "\033]0;BUSY $promptInput mode:$mode\007"
    
    ANGLE="1"
    ffmpeg -i $arg2 -vcodec libx264 -preset slow -crf 0 -vf transpose=$ANGLE -acodec copy $arg3

    echo -ne "\033]0;DONE $arg2 last mode:$mode\007"
}

#tuna-viDS for nintendo ds homebrew avi video player
tunaviDS() {
    local WIDTH=256
    local HEIGHT=192
    local promptInput=""
    local mode="TUNAviDS"
    echo mode set to $mode

    #setting title
    echo -ne "\033]0;BUSY $promptInput mode:$mode\007"

    ffmpeg -i $arg2 $arg4 -f avi -r 10 -s 256x192 -b:v 192k -bt 64k -vcodec mpeg4 -deinterlace -acodec libmp3lame -ar 32000 -ab 96k -ac 2 $arg3
    echo -ne "\033]0;DONE $arg2 last mode:$mode\007"
}

#$arg2 watermarkimage $arg3 inputvid $arg4 output vid
#bottom left corner
watermark() {
    local mode="Watermark"
    echo mode set to $mode
    
    echo -ne "\033]0;BUSY $promptInput mode:$mode\007"
    ffmpeg -i $arg3 -vf "movie=$arg2 [watermark]; [in][watermark] overlay=10:main_h-overlay_h-10 [out]" -acodec copy $arg4
    
    #ffmpeg -i $arg3 -i $arg2  -filter_complex \
    #"[1:v]scale=25:20[wat];[0:v][wat]overlay=10:main_h-overlay_h-10[outv]" \
    #-map "[outv]" -map 0:a -strict experimental $arg4

    #ffmpeg -y -i $arg3 -i $arg2 -filter_complex 'overlay=0:0' -s 1280x720  -acodec copy -strict experimental $arg4

    echo -ne "\033]0;DONE $arg2 last mode:$mode\007"
}

###AUDIO TOOLS

#adds cover art to arg3 directory with art file arg2
tagDirectory() {
##HAS ONLY BEEN TESTED IN CURRENT DIRECTORY
    local mode="Tag Directory"
    echo mode set to $mode
    
    echo -ne "\033]0;BUSY $promptInput mode:$mode\007"
    for f in $arg3/*.mp3
    do
        ffmpeg -i "$f" -i "$arg2" -map_metadata 0 -map 0 -map 1 out-"${f#./}" \
        && mv out-"${f#./}" "$f"
    done
}

###PLAYERS

play () {
    if [ -z "$arg2" ]
    then
        local promptInput=""
        read -p "type something to play:" promptInput
        arg2=$promptInput
    fi

    ffplay -framedrop -autoexit -fast -window_title "ffeasy play $arg2" $arg2 $arg3 $arg4
}

play1 () {
    if [ -z "$arg1" ]
    then
        local promptInput=""
        read -p "type something to play:" promptInput
        arg1="$promptInput"
    fi

    ffplay -framedrop -autoexit -window_title "ffeasy play $arg1" "$arg1"
}

display_vars () {
    echo 0 $0 1 $1 2 $2 3 $3
    echo a1 $arg1 a2 $arg2 a3 $arg3 a4 $arg4
    echo QUAL.... $QUAL
    echo WIDTH... $WIDTH
    echo HEIGHT.. $HEIGHT
    echo FPS..... $FPS
    echo ABR..... $ABR
}

#set title funtion
set_title () {
echo -ne "\033]0;$1\007"
}

##############MAIN or DRIVER#################
clear
set_title ffeasy

#check if there is no parameter passed in

if [ -z "$arg1" ]
then
    echo "No parameters passed in" 
    prompt_input
fi

check_input $arg1
#input, output, additional options 
#android $1 $2 $3