#!/bin/bash
echo "que empiezo" >> /tmp/cf_tmpfile
now=`date +%s`
#host=`cat /etc/environment|cut -d"@" -f 2|cut -d" " -f 1`
host=${1:-localhost}
port=8161
carbon_server=graphite.rickpc
tree=servers
servicename=activemq

if [ $host == "localhost" ];then 
  host=`hostname`
fi
date >> /tmp/mq_tmpfile

# Create queue temp file
queues_temp=/tmp/queues_temp
# Retrieve Active queue list via HTTP
`lynx http://$host:$port/admin/queues.jsp -accept_all_cookies -auth 'admin:ubitus' -dump -nolist | grep "Browse Active" > $queues_temp`

exec < $queues_temp

number=0
### list queues
while read line
do
  # Name | Number Of Pending Messages | Number Of Consumers | Messages Enqueued | Messages Dequeued
  queuename=`echo $line|cut -d" " -f1`
  num_pending=`echo $line|cut -d" " -f2`
  num_consumer=`echo $line|cut -d" " -f3`
  num_enqueued=`echo $line|cut -d" " -f4`
  num_dequeued=`echo $line|cut -d" " -f5`
  data="$data $tree.$host.$servicename.queues.$queuename.PendingMessages $num_pending $now\n"
	data="$data $tree.$host.$servicename.queues.$queuename.ConsumerNumber $num_consumer $now\n"
	data="$data $tree.$host.$servicename.queues.$queuename.EnqueuedMessages $num_enqueued $now\n"
	data="$data $tree.$host.$servicename.queues.$queuename.DequeuedMessages $num_dequeued $now\n"
	number=$((number+1))
done

data="$data $tree.$host.$servicename.queues.number $number $now\n"

#echo $data
echo -e $data | nc -w 5 $carbon_server 2003

# Delete queue temp file
`rm $queues_temp`

echo "que acabo" >> /tmp/mq_tmpfile
