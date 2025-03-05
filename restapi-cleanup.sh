#!/bin/bash
# Minimum Viable Exchange Federation
# Upstream servers are the servers towards where messages are originally published
# Downstream servers are where the messages get forwarded to

# 
# conn, err := amqp.Dial("amqp://ibg:ibg@192.168.0.242:5672/")
# Two clusters
CREDS="admin:admin"
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

printf "\nDelete federation policy on downstream\n---------------------------------------\n"
curl -i -X DELETE -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/policies/$VHOST/${POLICY_NAME}

printf "\nDelete upstream on downstream\n---------------------------------------\n"
curl -i -X DELETE -H "Content-Type:application/json" $HTTPS_DNSTREAM/api/parameters/federation-upstream/$VHOST/${UPSTREAM_NAME}

printf "\ndownstream queue\n---------------------------------------\n"
curl -i -X DELETE -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/queues/$VHOST/${QUEUE_NAME}
printf "\nupstream queue\n---------------------------------------\n"
curl -i -X DELETE -H "Content-Type: application/json" $HTTPS_UPSTREAM/api/queues/$VHOST/${QUEUE_NAME}

printf "\ndownstream exchange\n---------------------------------------\n"
curl -i -X DELETE -H "Content-Type: application/json" $HTTPS_DNSTREAM/api/exchanges/$VHOST/${EXCHANGE_NAME}/ 

# printf "\ndownstream binding\n---------------------------------------\n"
# curl -i -X DELETE -H 'Content-Type: application/json' $HTTPS_DNSTREAM/api/bindings/$VHOST/e/${EXCHANGE_NAME}/q/${QUEUE_NAME}
# printf "\nupstream binding\n---------------------------------------\n"
# curl -i -X DELETE -H 'Content-Type: application/json' $HTTPS_UPSTREAM/api/bindings/$VHOST/e/${EXCHANGE_NAME}/q/${QUEUE_NAME}

