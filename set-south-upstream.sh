docker exec -i rabbit-south rabbitmqctl clear_policy federation
docker exec -i rabbit-south rabbitmqctl clear_parameter federation-upstream my-upstream
docker exec -i rabbit-north rabbitmqctl set_parameter federation-upstream my-upstream '{"uri":"amqp://guest:guest@rabbit-south:5672","expires":3600000}'
docker exec -i rabbit-north rabbitmqctl set_policy --vhost "/" --apply-to "all" federation ".*" '{"federation-upstream-set": "all"}'
