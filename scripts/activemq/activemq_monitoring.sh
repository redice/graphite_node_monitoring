#!/bin/bash


#Carbon server where data should be stored for graphite to show - El servidor carbon on s'han de guardar les dades que mostra el graphite
carbon_server=graphite.rickpc
# Tree structure where we want information to be stored - L'estructura de l'arbre on volem que es guardin les dades a graphite. 
tree=servers

now=`date +%s`
host=${1:-localhost}

#Number of connections - Numero de connexions
if [ $host == "localhost" ];then 
  connections=`netstat -tn|grep ESTABLISHED|awk '{print $4}'|grep 5445|wc -l`
  host=`hostname`
else 
  connections=`ssh $host netstat -tn|grep ESTABLISHED|awk '{print $4}'|grep 5445|wc -l`
fi
data="$tree.$host.activemq.connections $connections $now\n" 

#echo -e $data
echo -e $data|nc -w 5 $carbon_server 2003
exit $?
