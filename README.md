# couchbase-for-swarm

NOT READY

This couchdb container works on a docker swarm and not need persistent volumes, is made to be used with many replicas to be able to recover anything if SOME node fail, and to be used with a proxy like traefik.

1) create your swarm, with managers and workers.

2) create an overlay network with a subnet

3) start the stack

4) (test) restart the master, restart a node and check the cluster pool and the data integrity


environment params:


      TYPE: MASTER
      AUTO_REBALANCE: 'true'
      DB_USER: 'maomao'
      DB_PASSW: 'zigozago'
      OVERLAYNET: '10.0.16'




