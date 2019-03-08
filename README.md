# Control-Script-for-OpenStack
Script that Checks for Errors in OpenStack Environment


The script which name is control.sh runs on Compute and Controller Nodes.

Running Script
After necessary installation for OpenStack, This script will be at /home dicrectory on the Controller Node. It should be run as administrator and its tasks are : 

Show Controller Node Services Status : It shows services status which run on Controller Node.

Show Compute Node Services Status : It shows services status which run on Controller Node using SSH.

Restart All Services on Controller Node : It restarts services which run on Controller Node.

Restart All Services on Compute Node :  It restarts services which run on Compute Node using SSH.

List Errors on Controller Node : It will scan the files that have been modified within the last 3 days, and then lists the last 15 errors in the / var / log directory on Controller Node.

List Errors on Compute Node : It will scan the files that have been modified within the last 3 days, and then lists the last 15 errors in the / var / log directory on Compute Node using SSH.

List Controller Node Warnings : It will scan the files that have been modified within the last 3 days, and then lists the last 15 warnings in the / var / log directory on Controller Node.

List Compute Node Warnings :  It will scan the files that have been modified within the last 3 days, and then lists the last 15 warnings in the / var / log directory on Compute Node using SSH.

Populate Service Databases : These are the commands used to create tables by reflecting the changes made in the configuration files during the installation to the database. It is added for core OpenStack services.

Required Directories for Files

control.sh -> /home/

controller_control.sh -> /home/

controller_servicelist -> /home/

compute_control.sh ->  root

compute_servicelist -> root

restart.sh -> root
