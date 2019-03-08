#!/bin/sh
inversvid="\0033[7m"
resetvid="\0033[0m"
greenback="\0033[1;37;42m"
blueback="\0033[1;37;44m"
redback="\0033[1;37;41m"



for f in $(cat /home/controller_servicelist);
do

sonuc=`/usr/sbin/service $f status  | /bin/grep "active (running)" | /usr/bin/wc -l`

if [ $sonuc -eq 1 ]
then
        echo  "$f $greenback Running $resetvid"
	if [ $sonuc != 1 ]
	then
	service $f restart
	fi
else
        echo  "$f $inversvid not Running $resetvid"
        service $f start
        sonuc=`/usr/sbin/service $f status  | /bin/grep "active (running)" | /usr/bin/wc -l`
        if [ $sonuc -eq 1 ]
        then
                echo "$f $blueback Started $resetvid"
        else
                echo "$redback $ERROR $resetvid  $f  Not Started"
        fi
fi

done;

