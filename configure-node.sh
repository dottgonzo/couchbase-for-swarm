#!/bin/bash

set -x
set -m

/entrypoint.sh couchbase-server &

sleep 60



# Setup index and memory quota
curl -v -X POST http://127.0.0.1:8091/pools/default -d memoryQuota=300 -d indexMemoryQuota=300

# Setup services
curl -v http://127.0.0.1:8091/node/controller/setupServices -d services=kv%2Cn1ql%2Cindex

# Setup credentials
curl -v http://127.0.0.1:8091/settings/web -d port=8091 -d username=$DB_USER -d password=$DB_PASSW

# Setup Memory Optimized Indexes
curl -i -u $DB_USER:$DB_PASSW -X POST http://127.0.0.1:8091/settings/indexes -d 'storageMode=memory_optimized'

# Load travel-sample bucket
#curl -v -u Administrator:password -X POST http://127.0.0.1:8091/sampleBuckets/install -d '["travel-sample"]'

echo "Type: $TYPE"



IP=$(ifconfig | grep $OVERLAYNET | sed 's/:/ /g' |awk '{print($3)}')





if [ $TYPE = 'WORKER' ]; then

sleeptime=$(( $(( ( RANDOM % 10 )  + 6 )) * $(( ( RANDOM % 10 )  + 6 )) ))

echo "Sleeping ...$sleeptime"
sleep $sleeptime




    if curl -u $DB_USER:$DB_PASSW --output /dev/null --silent --head --fail "http://$COUCHBASE_MASTER:8091/pools/default"; then
        
        curl -u $DB_USER:$DB_PASSW -d otpNode=ns_1@$IP http://$COUCHBASE_MASTER:8091/controller/failOver
        
        
        
        sleep 10
        
        curl -u $DB_USER:$DB_PASSW -d otpNode=ns_1@$IP http://$COUCHBASE_MASTER:8091/controller/ejectNode
        
        
        
        
        
        sleep 10
        
        couchbase-cli rebalance --cluster="$COUCHBASE_MASTER:8091" --user="$DB_USER" --password="$DB_PASSW" --server-add="$IP" --server-add-username="$DB_USER" --server-add-password="$DB_PASSW"
        
        
        
        fg 1
        exit
        
        
    fi
    
    
fi


ipslit=$(echo $IP | sed 's/\./ /g')

OVERLAYNET="$(echo $ipslit| awk '{print($1)}').$(echo $ipslit| awk '{print($2)}').$(echo $ipslit| awk '{print($3)}')"


all=$(nmap -sn $OVERLAYNET.0/24  -oG - | grep Host | grep $OVERLAYNET | grep -v "$IP" | grep -v $OVERLAYNET.1| awk '{print($2)}')

echo $all



for i in $all; do
    echo $i
    
    
    if curl -u $DB_USER:$DB_PASSW --output /dev/null --silent --head --fail "http://$i:8091/pools/default"; then
        
        
        sleep 10
        
        curl -u $DB_USER:$DB_PASSW -d otpNode=ns_1@$IP http://$i:8091/controller/failOver
        
        
        
        sleep 10
        
        curl -u $DB_USER:$DB_PASSW -d otpNode=ns_1@$IP http://$i:8091/controller/ejectNode
        
        
        
        
        
        sleep 10
        
        couchbase-cli rebalance --cluster="$i:8091" --user="$DB_USER" --password="$DB_PASSW" --server-add="$IP" --server-add-username="$DB_USER" --server-add-password="$DB_PASSW"
        
        
        
        
        
        echo "ok on $i"
        
        sleep 30
        
        break
        
        
    else
        
        echo "no $i"
        
        
        
    fi
    
    
    
    
done



fg 1
