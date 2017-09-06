#!/bin/bash

set -x
set -m

/entrypoint.sh couchbase-server &

sleep 60

if [ "$TYPE" == "MASTER" ]; then

nmap -sP 10.0.16.*

fi


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

if [ "$TYPE" == "WORKER" ]; then
  echo "Sleeping ..."
  sleep 60

  #IP=`hostname -s`
  IP=`hostname -I | cut -d ' ' -f1`
  echo "IP: " $IP

  echo "Auto Rebalance: $AUTO_REBALANCE"
  if [ "$AUTO_REBALANCE" = "true" ]; then
    couchbase-cli rebalance --cluster=$COUCHBASE_MASTER:8091 --user=$DB_USER --password=$DB_PASSW --server-add=$IP --server-add-username=$DB_USER --server-add-password=$DB_PASSW
  else
    couchbase-cli server-add --cluster=$COUCHBASE_MASTER:8091 --user=$DB_USER --password=$DB_PASSW --server-add=$IP --server-add-username=$DB_USER --server-add-password=$DB_PASSW
  fi;
fi;

fg 1