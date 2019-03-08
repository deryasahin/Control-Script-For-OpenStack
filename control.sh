#!/bin/bash

while  true
do

echo

echo -e "1) Show Services Status"
echo -e "\ta)Show Controller Node Services Status"
echo -e "\tb)Show Compute Node Services Status"

echo -e "2) Restart Services"
echo -e "\tc)Restart All Services on Controller Node"
echo -e "\td)Restart All Services on Compute Node"

echo -e "\n3) List Errors"
echo -e "\te)List Errors on Controller Node"
echo -e "\tf)List Errors on Compute Node"

echo -e "\n4) List Warnings"
echo -e "\tg)List Controller Node Warnings"
echo -e "\th)List Compute Node Warnings"

echo -e "\n5) Populate Service Databases"
echo -e "\ti)Keystone"
echo -e "\tj)Glance"
echo -e "\tk)Nova"
echo -e "\tl)Neutron"

echo -e "\n---> Çıkış için herhangi bir tuşa basınız. \n"

read -p "Bir secim yapın: " opt

case $opt in

	'a')
		echo -e "\nListing Controller Node Services Status...\n"
		cd /home
		./controller_control.sh
	;;

	'b')
                IP_Remote="10.0.0.31"
                User="root"
                Password="root123"

		echo -e "\nListing Compute Node Services Status...\n"
		sshpass -p $Password ssh $User@$IP_Remote "/./compute_control.sh"


	;;

	'c')
		echo -e "\nRestarting All Services on Controller Node... \n"
	        for serv in $(cat /home/controller_servicelist)
		do
	        	service $serv restart
	        	status=`/usr/sbin/service $serv status  | /bin/grep "active (running)" | /usr/bin/wc -l`
	        	if [ $status -eq 1 ]
	        	then
	        	        echo -e "$serv \e[44m Restarted \e[0m"
	        	else
	        	        echo -e "$serv   \e[97;41m Not Started \e[0m"
	        	fi

		done


	;;



        'd')
                IP_Remote="10.0.0.31"
                User="root"
                Password="root123"
		echo -e "\nRestarting All Services on Compute Node... \n"
		sshpass -p $Password ssh $User@$IP_Remote "/./restart.sh"

        ;;





	'e')

		cd /home

		echo -e "\nFinding Controller Node Errors...\n"
                if [ `ls /home | grep errorlist | wc -l` -eq 1 ]
		then
        		rm -f errorlist
		fi
		cd /var/log
                a=`ls | find -name '*log' -type f -mtime -3  | wc -l`
		(( flag=0  ))
                while (( $a != 0  ))
                do
                        file_name=`ls | find -type f -mtime -3 | head -$a | tail -1`
                        if [ `grep -ai "ERROR" $file_name | wc -l` -ne 0 ]
                        then
				(( flag++  ))
                                echo -e "$flag)$file_name" >> /home/errorlist
                        fi
                        (( a--  ))
                done;


                while true
                do
                        if [ $flag -eq 0 ]
                        then
                                echo -e "\nThere is no error!\n\n"
                                break
                        else
                        	echo -e "Errors on Controller Node \n"
                        	more /home/errorlist
                        	echo -e "\n"
                        	read -p "Lütfen içeriğini görüntülemek istediğiniz dosyanın numarasını giriniz, çıkış için q'ya basınız : " Number_Of_File
                        	echo
                        	if ! [[ "$Number_Of_File" =~ ^[0-9]+$ ]]
                        	then
                                	if [ $Number_Of_File == "q" ]
                                	then
                                	        break
                                	fi
                                	echo -e "Lütfen sayısal bir değer giriniz.\n"
                        	else
                                	if [ $Number_Of_File -eq 0 ] || [ $Number_Of_File -gt $flag ]
                                	then
                                	        echo -e "Girdiğiniz değer bulunan dosya sayısından fazla veya 0'a eşit. Lütfen tekrar deneyiniz.\n"
                                	else
                                	        file=`cut -d")" -f2 /home/errorlist | sed 's/ERROR//' |  head -$Number_Of_File | tail -1`
                                	        FileName_FullPath="/var/log/"$file
                                       		echo -e "\n\n $FileName_FullPath Errors : \n"
                                        	more $FileName_FullPath | grep -ai "ERROR" | tail -15
						echo
						echo

                                	fi
                        	fi
			fi

                done



	;;


	'f')

		echo -e "\nFinding Compute Node Errors...\n"

		IP_Remote="10.0.0.31"
		User="root"
		Password="root123"
		LOG_Dir="/var/log"

		for_compute_script=`sshpass -p $Password ssh $User@$IP_Remote "ls /home | grep For_Script | wc -l"` 
		if [ $for_compute_script -eq 0 ]
		then
			sshpass -p $Password ssh $User@$IP_Remote "mkdir /home/For_Script"
		fi

		if [ `ls /home | grep For_Compute | wc -l` -eq 0 ]
                then
                        mkdir /home/For_Compute
                fi


		File_List_Remote="/home/For_Script/FileList.txt"
		Error_Files="/home/For_Compute/Error_Files_List.txt"

		Log_File_Count=`sshpass -p $Password ssh $User@$IP_Remote "find $LOG_Dir -name '*log' -type f -mtime -3 | wc -l"`

		sshpass -p $Password ssh $User@$IP_Remote "rm -f $File_List_Remote"
		rm -f $Error_Files

		sshpass -p $Password ssh $User@$IP_Remote "find $LOG_Dir -name '*log' -type f -mtime -3 > $File_List_Remote"
		Modified_Files_Count=0

		for (( i=1; i<=$Log_File_Count; i++ ))
		do
			File_Name_Temp=`sshpass -p $Password ssh $User@$IP_Remote "cat $File_List_Remote | head -$i | tail -1"` 
			Error_Count=`sshpass -p $Password ssh $User@$IP_Remote "cat $File_Name_Temp | tail -100 | grep -ai 'ERROR' | wc -l"`
			if [ $Error_Count -ne 0 ]
			then
			(( Modified_Files_Count++ ))
				echo -e "$Modified_Files_Count  ) $File_Name_Temp">> $Error_Files
			fi
		done
		Error_Files_Count=`cat $Error_Files | wc -l`
		while true
		do
			echo -e "Errors on Compute Node \n"
			more $Error_Files
			echo -e "\n"
			read -p "Lütfen içeriğini görüntülemek istediğiniz dosyanın numarasını giriniz, çıkış için q'ya basınız :  " Number_Of_File
			echo
			if ! [[ "$Number_Of_File" =~ ^[0-9]+$ ]]
			then
				if [ $Number_Of_File == "q" ]
				then
					break
				fi
				echo -e "Lütfen sayısal bir değer giriniz.\n"
			else
				if [ $Number_Of_File -eq 0 ] || [ $Number_Of_File -gt $Error_Files_Count ]
				then
					echo -e "Girdiğiniz değer bulunan dosya sayısından fazla veya 0'a eşit. Lütfen tekrar deneyiniz.\n"
				else
					File_Name=`more $Error_Files | head -$Number_Of_File | tail -1`
					File_Name=`echo $File_Name | awk '{print $3}'`
					echo -e "\n$File_Name Errors\n"
					sshpass -p $Password ssh $User@$IP_Remote "cat $File_Name | grep -ai 'ERROR' | tail -10"
					echo -e "\n"
				fi
			fi

		done

	;;






       'g')
                cd /home
                echo -e "\nFinding Controller Node Warnings...\n"
                if [ `ls /home | grep warninglist | wc -l` -eq 1 ]
                then
                        rm -f warninglist
                fi
                cd /var/log
                a=`ls | find -name '*log' -type f -mtime -3  | wc -l`
                (( flag=0  ))
                while (( $a != 0  ))
                do
                        file_name=`ls | find -type f -mtime -3 | head -$a | tail -1`
                        if [ `grep -ai "warnings" $file_name | wc -l` -ne 0 ]
                        then
                                (( flag++  ))
                                echo -e "$flag)$file_name WARNING" >> /home/warninglist
                        fi
                        (( a--  ))
                done;


                while true
                do
                        if [ $flag -eq 0 ]
                        then
                                echo -e "\nThere is no warning!\n\n"
                                break
                        else
                                echo -e "Warnings on Controller Node \n"
                                more /home/warninglist
                                echo -e "\n"
                                read -p "Lütfen içeriğini görüntülemek istediğiniz dosyanın numarasını giriniz, çıkış için q'ya basınız :  " Number_Of_File
                                echo
                                if ! [[ "$Number_Of_File" =~ ^[0-9]+$ ]]
                                then
                                        if [ $Number_Of_File == "q" ]
                                        then
                                                break
                                        fi
                                        echo -e "Lütfen sayısal bir değer giriniz.\n"
                                else
                                        if [ $Number_Of_File -eq 0 ] || [ $Number_Of_File -gt $flag ]
                                        then
                                                echo -e "Girdiğiniz değer bulunan dosya sayısından fazla veya 0'a eşit. Lütfen tekrar deneyiniz.\n"
                                        else
                                                file=`cat /home/warninglist | sed 's/WARNING//' | tr -d ' ' | cut -d ')' -f2  | sed 's/^.//g' |  head -$Number_Of_File | tail -1`
                                                FileName_FullPath="/var/log"$file
                                                echo -e "\n\n $FileName_FullPath Warnings : \n"
						/bin/cat $FileName_FullPath | grep -ai "WARNING" | tail -15
                                                echo
                                                echo

                                        fi
                                fi
                        fi

                done



        ;;

        'h')

                echo -e "\nFinding Compute Node Warnings...\n"

                IP_Remote="10.0.0.31"
                User="root"
                Password="root123"
                LOG_Dir="/var/log"

                for_compute_script=`sshpass -p $Password ssh $User@$IP_Remote "ls /home | grep For_Script | wc -l"`
                if [ $for_compute_script -eq 0 ]
                then
                        sshpass -p $Password ssh $User@$IP_Remote "mkdir /home/For_Script"
                fi

                if [ `ls /home | grep For_Compute | wc -l` -eq 0 ]
                then
                        mkdir /home/For_Compute
                fi


                Warnings_File_List_Remote="/home/For_Script/WarningFileList.txt"
                Warning_Files="/home/For_Compute/Warning_Files_List.txt"

                Log_File_Count=`sshpass -p $Password ssh $User@$IP_Remote "find $LOG_Dir -name '*log' -type f -mtime -3 | wc -l"`

                sshpass -p $Password ssh $User@$IP_Remote "rm -f $Warnings_File_List_Remote"
                rm -f $Warning_Files

                sshpass -p $Password ssh $User@$IP_Remote "find $LOG_Dir -name '*log' -type f -mtime -3 > $Warnings_File_List_Remote"
                Modified_Files_Count=0

                for (( i=1; i<=$Log_File_Count; i++ ))
                do
                        File_Name_Temp=`sshpass -p $Password ssh $User@$IP_Remote "cat $Warnings_File_List_Remote | head -$i | tail -1"`
                        Warning_Count=`sshpass -p $Password ssh $User@$IP_Remote "cat $File_Name_Temp | tail -100 | grep -i 'WARNING' | wc -l"`
                        if [ $Warning_Count -ne 0 ]
                        then
                        (( Modified_Files_Count++ ))
                        echo -e "$Modified_Files_Count  ) $File_Name_Temp WARNING">> $Warning_Files
                        fi
                done
                Warning_Files_Count=`cat $Warning_Files | wc -l`
                while true
                do
                        echo -e "Warnings on Compute Node \n"
                        more $Warning_Files
                        echo -e "\n"
                        read -p "Lütfen içeriğini görüntülemek istediğiniz dosyanın numarasını giriniz, çıkış için q'ya basınız : " Number_Of_File
                        echo
                        if ! [[ "$Number_Of_File" =~ ^[0-9]+$ ]]
                        then
                                if [ $Number_Of_File == "q" ]
                                then
                                        break
                                fi
                                echo -e "Lütfen sayısal bir değer giriniz.\n"
                        else
                                if [ $Number_Of_File -eq 0 ] || [ $Number_Of_File -gt $Warning_Files_Count ]
                                then
                                        echo -e "Girdiğiniz değer bulunan dosya sayısından fazla veya 0'a eşit. Lütfen tekrar deneyiniz.\n"
                                else
                                        File_Name=`more $Warning_Files | head -$Number_Of_File | tail -1`
                                        File_Name=`echo $File_Name | awk '{print $3}'`
                                        echo -e "\n$File_Name Warnings\n"
                                        sshpass -p $Password ssh $User@$IP_Remote "cat $File_Name | grep -ai 'WARNING' | tail -10"
                                        echo -e "\n"
                                fi
                        fi

                done

        ;;


	'i')

		echo -e "\nPopulating Keystone Database... \n"

		su -s /bin/sh -c "keystone-manage db_sync" keystone

                output=`mysql -u root <<EOF_SQL
use mysql;
use keystone;
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'keystone';
exit
EOF_SQL`

		t=`echo $output | rev | cut -d' ' -f1 | rev`

		if [ $t -ne 0 ]
		then
			echo -e "\n\e[42m Successful \e[0m\n"
		else
			echo -e "\n\e[97;41m ERROR \e[0m \n"
		fi


	;;


        'j')

                echo -e "\nPopulating Glance Database... \n"
                su -s /bin/sh -c "glance-manage db_sync" glance


                output=`mysql -u root <<EOF_SQL
use mysql;
use keystone;
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'keystone';
exit
EOF_SQL`

                t=`echo $output | rev | cut -d' ' -f1 | rev`

                if [ $t -ne 0 ]
                then
                        echo -e "\n\e[42m Successful \e[0m\n"
                else
                        echo -e "\n\e[97;41m ERROR \e[0m \n"
                fi




        ;;

        'k')

                echo -e "\nPopulating Nova Database... \n"
                su -s /bin/sh -c "nova-manage api_db sync" nova


                output=`mysql -u root <<EOF_SQL
use mysql;
use keystone;
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'keystone';
exit
EOF_SQL`

                t=`echo $output | rev | cut -d' ' -f1 | rev`

                if [ $t -ne 0 ]
                then
                        echo -e "\n\e[42m Successful \e[0m\n"
                else
                        echo -e "\n\e[97;41m ERROR \e[0m \n"
                fi




	;;

	'l')

		echo -e "\nPopulating Neutron Database... \n"

		su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

                output=`mysql -u root <<EOF_SQL
use mysql;
use keystone;
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'keystone';
exit
EOF_SQL`

                t=`echo $output | rev | cut -d' ' -f1 | rev`

                if [ $t -ne 0 ]
                then
                        echo -e "\n\e[42m Successful \e[0m\n"
                else
                        echo -e "\n\e[97;41m ERROR \e[0m \n"
                fi



	;;


	*)

		break

		;;
esac

done

