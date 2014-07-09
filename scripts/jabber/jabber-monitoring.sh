#!/bin/bash

#Carbon server where data should be stored for graphite to show - El servidor carbon on s'han de guardar les dades que mostra el graphite
carbon_server=graphite.rickpc

# Tree structure where we want information to be stored - L'estructura de l'arbre on volem que es guardin les dades a graphite. 
tree="servers" #In this case, info will be shown in graphite as "servers.servername.loadavg_1min". We could use "pro" and "pre" to separate environments: "servers.pro.servername.loadavg_1min" - En el nostre cas es veuran a "servers.servername.loadavg_1min". Podriem posar "prod" i "pre" per separar entorns: "servers.pro.servername.loadavg_1min"

now=`date +%s`
host=`hostname`

ASSEMBLY_HOME="/home/ubitus/gc.assembly"
APP_NAME="jabber"

###
### Collect Jabber log information ###
###
log_folder="/logs/monitor"

# collect jabberTcpConnectionCount in tcp.connection.log
count=`cat $ASSEMBLY_HOME/$APP_NAME/$log_folder/tcp.connection.log | awk '{print $2}' | awk -F, 'BEGIN{FS=":"}{print $2}'`
data="$tree.$host.$APP_NAME.tcpConnection.count $count $now \n"

# collect currentGameProcessCount, currentDisconnectedGameProcessCount in gameprocess.log
temp=`cat $ASSEMBLY_HOME/$APP_NAME/$log_folder/gameprocess.log | awk '{print $2}'`
echo "temp = $temp"
count=`echo $temp | awk -F, 'BEGIN{FS=","}{print $1}'| awk -F, 'BEGIN{FS=":"}{print $2}'`
data="$data $tree.$host.$APP_NAME.gameProcess.currentCount $count $now \n"
disconnectedCount=`echo $temp | awk -F, 'BEGIN{FS=","}{print $2}'| awk -F, 'BEGIN{FS=":"}{print $2}'`
data="$data $tree.$host.$APP_NAME.gameProcess.currentDisconnectedCount $disconnectedCount $now \n"

### All log files ###
#ls -al /home/ubitus/gc.assembly/jabber/logs/monitor|awk '{print $9}'|grep log

#Show data for debugging purpose - Mostrem les dades per depurar errors
#echo $data

#Send data to graphite - Enviem dades a graphite
echo -e $data |nc -w 5 $carbon_server 2003 2>&2

exit $?