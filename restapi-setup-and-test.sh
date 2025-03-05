#!/bin/bash
# Minimum Viable Exchange Federation
# Upstream servers are the servers towards where messages are originally published
# Downstream servers are where the messages get forwarded to

# Two clusters
CREDS="guest:guest"
VHOST="%2F"
UPHOST="192.168.0.241"
DOWNHOST="192.168.0.242"

POLICY_NAME="federation-policy"
EXCHANGE_NAME="federation-exchange"
QUEUE_NAME="ppg00"
RKEY="ppg00"
UPSTREAM_NAME="federation-upstream"
UPSTREAM_URL="amqp://$CREDS@${UPHOST}:5672"
HTTPS_DNSTREAM="http://$CREDS@${DOWNHOST}:15672"
HTTPS_UPSTREAM="http://$CREDS@${UPHOST}:15672"

printf "\nCreate a federation policy on downstream\n---------------------------------------\n"
# curl -i -X PUT -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/policies/$VHOST/${POLICY_NAME}/ \
#      -d '{"pattern":"^fedtest$", "definition": {"federation-upstream-set":"all"}, "priority":0, "apply-to": "exchanges"}'

curl -i -X PUT -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/policies/$VHOST/${POLICY_NAME}/ \
      -d '{"pattern":".*", "definition": {"federation-upstream-set":"all"}, "priority":0, "apply-to": "exchanges"}'

# printf "\nCreate queue policy on downstream (matching all queues in the vhost!)\n---------------------------------------\n"
# curl -i -X PUT -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/policies/$VHOST/maxlen/ \
#      -d '{"pattern":".", "definition": {"max-length":10000}, "priority":0, "apply-to": "queues"}'

printf "\nSet upstream parameter on downstream\n---------------------------------------\n"
curl -i -X PUT -H "Content-Type:application/json" $HTTPS_DNSTREAM/api/parameters/federation-upstream/$VHOST/${UPSTREAM_NAME} \
       -d '{"value":{"uri":"'$UPSTREAM_URL'","expires":36000000}}' 

printf "\ndownstream queue\n---------------------------------------\n"
curl -i -X PUT -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/queues/$VHOST/${QUEUE_NAME}/ \
      -d '{"auto_delete":true,"durable":true,"arguments":{}}'
printf "\nupstream queue\n---------------------------------------\n"
curl -i -X PUT -H "Content-Type: application/json" $HTTPS_UPSTREAM/api/queues/$VHOST/${QUEUE_NAME}/ \
      -d '{"auto_delete":true,"durable":true,"arguments":{}}'

printf "\ndownstream exchange\n---------------------------------------\n"
curl -i -X PUT -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/exchanges/$VHOST/${EXCHANGE_NAME}/ \
      -d '{"type":"direct","auto_delete":true,"durable":false,"internal":false}'

printf "\ndownstream binding\n---------------------------------------\n"
curl -i -X POST -H 'Content-Type: application/json' $HTTPS_DNSTREAM/api/bindings/$VHOST/e/${EXCHANGE_NAME}/q/${QUEUE_NAME} \
      -d '{"routing_key":"'${RKEY}'"}'
printf "\nupstream binding\n---------------------------------------\n"
curl -i -X POST -H 'Content-Type: application/json' $HTTPS_UPSTREAM/api/bindings/$VHOST/e/${EXCHANGE_NAME}/q/${QUEUE_NAME} \
      -d '{"routing_key":"'${RKEY}'"}'

printf "\nPause to avoid race condition\n---------------------------------------\n"
sleep 5

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

