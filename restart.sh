#/bin/bash

for f in $(cat 	/compute_servicelist);
do
	service $f restart
	echo -e "$f \e[44m Restarted \e[0m"
done

