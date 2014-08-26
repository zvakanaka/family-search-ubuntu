#!/bin/bash
#Familysearch Indexing does not currently install on 64 bit 
#Ubuntu 14.04(or 64 bit linux in general).
#This script runs necessary commands to fix that.
#I take no credit, but thank Google and this guy:
#http://software.jamezone.org/HOWTO/familysearchindexing.html

echo "DOWNLOADING ORIGINAL INSTALLER"
wget -c https://indexing.familysearch.org/downloads/Indexing_unix.sh
echo "DONE"
echo '--- Indexing_unix.sh.orig	2013-11-05 11:34:03.000000000 -0700
+++ Indexing_unix.sh	2013-11-17 20:23:14.782527336 -0700
@@ -348,6 +348,9 @@
   cd ..
 fi
 
+for f in "$bundled_jre_home"/bin/*; do
+  ln -fs /usr/lib/jvm/java-6-openjdk-amd64/bin/$(basename $f) "$f"
+done
 run_unpack200 "$bundled_jre_home"
 run_unpack200 "$bundled_jre_home/jre"
 else' > Indexing_unix.PATCH

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
echo '"It will be alright in the end"'
chmod +x Indexing_unix.sh
./Indexing_unix.sh