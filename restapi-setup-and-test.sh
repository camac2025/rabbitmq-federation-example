#!/bin/bash
# Minimum Viable Exchange Federation
# Upstream servers are the servers towards where messages are originally published
# Downstream servers are where the messages get forwarded to

# 
# conn, err := amqp.Dial("amqp://ibg:ibg@192.168.0.242:5672/")
# Two clusters
CREDS="guest:guest"
VHOST="%2F"
UPHOST="192.168.0.200"
DOWNHOST="192.168.0.200"
EXCHANGE="fedtest"
RKEY="fedq00"

UPSTREAM_URL="amqp://$CREDS@${UPHOST}:5672"
HTTPS_DNSTREAM="http://$CREDS@${DOWNHOST}:15673"
HTTPS_UPSTREAM="http://$CREDS@${UPHOST}:15672"

printf "\nCreate a federation policy on downstream\n---------------------------------------\n"
curl -i -X PUT -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/policies/$VHOST/fedpolicy/ -d '{"pattern":"^fedtest$", "definition": {"federation-upstream-set":"all"}, "priority":0, "apply-to": "exchanges"}'

printf "\nCreate queue policy on downstream (matching all queues in the vhost!)\n---------------------------------------\n"
curl -i -X PUT -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/policies/$VHOST/maxlen/ -d '{"pattern":".", "definition": {"max-length":10000}, "priority":0, "apply-to": "queues"}'

printf "\nCreate upstream on downstream\n---------------------------------------\n"
curl -i -X PUT -H "Content-Type:application/json" $HTTPS_DNSTREAM/api/parameters/federation-upstream/$VHOST/upstream -d '{"value":{"uri":"'$UPSTREAM_URL'","expires":36000000}}' 

printf "\ndownstream queue\n---------------------------------------\n"
curl -i -X PUT -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/queues/$VHOST/fedq00/ -d '{"auto_delete":true,"durable":true,"arguments":{}}'
printf "\nupstream queue\n---------------------------------------\n"
curl -i -X PUT -H "Content-Type: application/json" $HTTPS_UPSTREAM/api/queues/$VHOST/fedq00/ -d '{"auto_delete":true,"durable":true,"arguments":{}}'

printf "\ndownstream exchange\n---------------------------------------\n"
#curl -i -X PUT -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/exchanges/$VHOST/${EXCHANGE}/ -d '{"type":"direct","auto_delete":false,"durable":true,"internal":false}'
curl -i -X PUT -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/exchanges/$VHOST/${EXCHANGE}/ -d '{"type":"direct","auto_delete":true,"durable":false,"internal":false}'

printf "\ndownstream binding\n---------------------------------------\n"
curl -i -X POST -H 'Content-Type: application/json' $HTTPS_DNSTREAM/api/bindings/$VHOST/e/${EXCHANGE}/q/fedq00 -d '{"routing_key":"'${RKEY}'"}'
printf "\nupstream binding\n---------------------------------------\n"
curl -i -X POST -H 'Content-Type: application/json' $HTTPS_UPSTREAM/api/bindings/$VHOST/e/${EXCHANGE}/q/fedq00 -d '{"routing_key":"'${RKEY}'"}'

#Publish a message to upstream - will end up on both upstream and downstream
printf "\npublish\n---------------------------------------\n"
curl -i -X POST -H "Content-Type: text/plain" "$HTTPS_UPSTREAM/api/exchanges/$VHOST/${EXCHANGE}/publish" \
      -d '{"properties":{},"routing_key":"'${RKEY}'","payload":"my body","payload_encoding":"string"}'
          
