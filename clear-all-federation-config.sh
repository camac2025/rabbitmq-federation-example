docker exec -i rabbit-south rabbitmqctl clear_policy federation
docker exec -i rabbit-south rabbitmqctl clear_parameter federation-upstream my-upstream
docker exec -i rabbit-south rabbitmqadmin delete exchange name="fedtest"
docker exec -i rabbit-south rabbitmqadmin delete queue name="fedq00"

docker exec -i rabbit-north rabbitmqctl clear_policy federation
docker exec -i rabbit-north rabbitmqctl clear_parameter federation-upstream my-upstream
docker exec -i rabbit-north rabbitmqadmin delete exchange name="fedtest"
docker exec -i rabbit-north rabbitmqadmin delete queue name="fedq00"
