FROM couchbase:latest

RUN apt update && apt install nmap jq -y

COPY configure-node.sh /opt/couchbase

#HEALTHCHECK --interval=5s --timeout=3s CMD curl --fail http://localhost:8091/pools || exit 1

CMD ["/opt/couchbase/configure-node.sh"]

