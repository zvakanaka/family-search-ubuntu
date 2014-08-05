#!/bin/bash
#Familysearch Indexing does not currently install on 64 bit 
#Ubuntu 14.04(or 64 bit linux in general).
#This script runs necessary commands to fix that.
#All fixes are not mine, find the links in LINKS.txt

echo "DOWNLOADING ORIGINAL INSTALLER"
wget -c https://indexing.familysearch.org/downloads/Indexing_unix.sh
echo "DONE"

echo "APPLYING PATCH"
patch Indexing_unix.sh Indexing_unix.PATCH
echo "DONE"

#libraries and finally, java jre 6 
sudo apt-get install -y libgtk2.0-0:i386 libxtst6:i386 libxtst6:i386 libx11-dev:i386  lib32z1 lib32ncurses5 lib32bz2-1.0 libxi6 libxtst6 libxrender1

sudo apt-get install -y openjdk-6-jre

echo "UPDATING PATHS TO JAVA 6"
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.6.0-openjdk-amd64/jre/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.6.0-openjdk-amd64/jre/bin/javac" 1

echo "NOTICE: ICED TEA WILL THROW ERRORS.  JUST CLICK OKAY."
echo "It will be alright in the end"
chmod +x Indexing_unix.sh
./Indexing_unix.sh