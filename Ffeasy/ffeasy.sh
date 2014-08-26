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
        cutf)
            cutFront
            ;;
        cutba)
            cutBack
            ;;
        cutbo)
            cutBoth
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
        "wii")
            wii
            ;;
        tag*)
            tagDirectory
            ;;
        "")
            cat $INSTALLPATH/options.txt
            ;;
        *)
            #quick hack, fix later
            #play1
            #add-IF one param, PLAY that one param  
            Message="Is this guy speaking English?"
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

    if [ -z "$arg3" ]
    then
        arg3="${arg2%.*}$mode.${arg2#*.}"
    fi

    ffmpeg -i $arg2 $arg4 -vcodec libx264 -profile:v high -preset fast -b:v $VBR -maxrate $VBR -bufsize 1000k -vf scale=$WIDTH:-1 -threads 0 -acodec aac -strict experimental -b:a $ABR -ac 2 -ab 44100 $arg3
}

#ss start second cut, keeps quality
#$arg2: inputFile $arg4: outputFile $arg3: startSecond 
cutFront() {
    local mode="CutFront"
    echo mode set to $mode
    if [ -z "$arg4" ]
    then
        arg4=$arg3
        arg3="${arg2%.*}$mode.${arg2#*.}"
    fi
    ffmpeg -i $arg2 -ss $arg4 -c copy $arg3
}

#t seconds terminate, keeps quality
#$arg2 inputFile $arg3 outputFile $arg4 terminateSecond 
cutBack() {
    local mode="CutBack"
    echo mode set to $mode
    if [ -z "$arg4" ]
    then
        arg4=$arg3
        arg3="${arg2%.*}$mode.${arg2#*.}"
    fi
    ffmpeg -i $arg2 -t $arg4 -acodec copy -vcodec copy -map 0$arg3
}

#$arg2 inputFile $arg3 outputFile $arg4 startSecond $arg5 terminateSecond 
cutBoth() {
    local mode="CutBoth"
    echo mode set to $mode
    if [ -z "$arg5" ]
    then
        arg5=$arg4
        arg4=$arg3
        arg3="${arg2%.*}$mode.${arg2#*.}"
    fi
    ffmpeg -i $arg2 -ss $arg4 -t $arg5 -c copy -map 0 $arg3
}

#convert for wii, first wiimc, then photochannel if possible 
wii () {
    local WIDTH=800
    local HEIGHT=480
    local QUAL=3
    #new string
    local promptInput=""
    local mode="Wii"
    echo mode set to $mode

    if [ -z "$arg3" ]
    then
        arg3="${arg2%.*}$mode.avi"
    fi
    #setting title
    echo -ne "\033]0;BUSY $promptInput mode:$mode $arg3\007"

    ffmpeg -i $arg2 $arg4 -vcodec mpeg4 -q $QUAL -preset medium -b:v 500k -vf scale=$WIDTH:-1 -threads 0 -acodec mp3 -strict experimental -b:a $ABR -ac 1 -ab 44100 $arg3
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
}

#ROTATE clockwise for the moment
rotate() {
    local promptInput=""
    local mode="ROTATE"
    echo mode set to $mode
    echo -ne "\033]0;BUSY $promptInput mode:$mode\007"
    
    ANGLE="1"
    ffmpeg -i $arg2 -vcodec libx264 -preset slow -crf 0 -vf transpose=$ANGLE -acodec copy $arg3
}

#tuna-viDS for nintendo ds homebrew avi video player
tunaviDS() {
    local WIDTH=256
    local HEIGHT=192
    local promptInput=""
    local mode="TUNAviDS"
    echo mode set to $mode
    if [ -z "$arg3" ]
    then
        echo NO ARG3
        arg3="${arg2%.*}$mode.avi"
    fi
    #setting title
    echo -ne "\033]0;BUSY $promptInput mode:$mode\007"

    ffmpeg -i $arg2 $arg4 -f avi -r 10 -s 256x192 -b:v 192k -bt 64k -vcodec mpeg4 -deinterlace -acodec libmp3lame -ar 32000 -ab 96k -ac 2 $arg3
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
        arg2="$promptInput"
    fi

    ffplay -framedrop -autoexit -fast -fs -window_title "ffeasy play $arg2" "$arg2" $arg3 $arg4
}

display_vars () {
    echo "0 $0, 1 $1, 2 $2, 3 $3, 4 $4, 5 $5"
    echo "arg1 $arg1, arg2 $arg2, arg3 $arg3, arg4 $arg4, arg5 $arg5" 
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