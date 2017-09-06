#! /bin/bash


IP=`hostname -I | cut -d ' ' -f1`

ipslit=$(echo $IP | sed 's/\./ /g')

OVERLAYNET="$(echo $ipslit| awk '{print($1)}').$(echo $ipslit| awk '{print($2)}').$(echo $ipslit| awk '{print($3)}')"

all=$(nmap -n -sP $OVERLAYNET.*  -oG - | awk '/Up$/{print $2}' | grep $OVERLAYNET | grep -v "$IP" | grep -v $OVERLAYNET.1)

for i in $all; do


curl -u $DB_USER:$DB_PASSW -d otpNode=ns_1@$IP $i:8091/controller/failOver


if [ $? == 0 ]; then

sleep 5

curl -u $DB_USER:$DB_PASSW -d otpNode=ns_1@$IP $i:8091/controller/ejectNode


sleep 5

fi

    couchbase-cli rebalance --cluster="$i:8091" --user="$DB_USER" --password="$DB_PASSW" --server-add="$IP" --server-add-username="$DB_USER" --server-add-password="$DB_PASSW"

if [ $? == 0 ]; then

echo "ok on $i"

break

else

echo "no $i"



fi

sleep 1

done

echo 'ok'

# curl -u maomao:zigozago http://10.0.16.7:8091/pools/nodes | jq '.nodes[].hostname ' | sed 's/"//g'|sed 's/:/ /g'| awk '{print($1)}'

