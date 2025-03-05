#!/bin/bash
# Upstream servers are the servers towards where messages are originally published
# Downstream servers are where the messages get forwarded to

# Two clusters
CREDS="admin:admin"
VHOST="%2F"
UPHOST="192.168.0.241"
DOWNHOST="192.168.0.242"

EXCHANGE_NAME="federation-exchange"
QUEUE_NAME="ppg00"
RKEY="ppg00"

HTTPS_DNSTREAM="http://$CREDS@${DOWNHOST}:15672"
HTTPS_UPSTREAM="http://$CREDS@${UPHOST}:15672"

#Publish a message to upstream - will end up on both upstream and downstream
printf "\npublish\n---------------------------------------\n"
curl -i -X POST -H "Content-Type: text/plain" "$HTTPS_UPSTREAM/api/exchanges/$VHOST/${EXCHANGE_NAME}/publish" \
      -d '{"properties":{},"routing_key":"'${RKEY}'","payload":"msg1","payload_encoding":"string"}'

curl -i -X POST -H "Content-Type: text/plain" "$HTTPS_UPSTREAM/api/exchanges/$VHOST/${EXCHANGE_NAME}/publish" \
      -d '{"properties":{},"routing_key":"'${RKEY}'","payload":"msg2","payload_encoding":"string"}'

curl -i -X POST -H "Content-Type: text/plain" "$HTTPS_UPSTREAM/api/exchanges/$VHOST/${EXCHANGE_NAME}/publish" \
      -d '{"properties":{},"routing_key":"'${RKEY}'","payload":"msg3","payload_encoding":"string"}'

curl -i -X POST -H "Content-Type: text/plain" "$HTTPS_UPSTREAM/api/exchanges/$VHOST/${EXCHANGE_NAME}/publish" \
      -d '{"properties":{},"routing_key":"'${RKEY}'","payload":"msg4","payload_encoding":"string"}'

