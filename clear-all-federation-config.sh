docker exec -i rabbit-south rabbitmqctl clear_policy fedit
docker exec -i rabbit-south rabbitmqctl clear_policy fedpolicy
docker exec -i rabbit-south rabbitmqctl clear_policy federation
docker exec -i rabbit-south rabbitmqctl clear_parameter federation-upstream upstream
docker exec -i rabbit-south rabbitmqadmin delete exchange name="fedtest"
docker exec -i rabbit-south rabbitmqadmin delete queue name="fedq00"
docker exec -i rabbit-south rabbitmqadmin delete queue name="q1"

docker exec -i rabbit-north rabbitmqctl clear_policy fedit
docker exec -i rabbit-north rabbitmqctl clear_policy fedpolicy
docker exec -i rabbit-north rabbitmqctl clear_policy federation
docker exec -i rabbit-north rabbitmqctl clear_parameter federation-upstream upstream
docker exec -i rabbit-north rabbitmqadmin delete exchange name="fedtest"
docker exec -i rabbit-north rabbitmqadmin delete queue name="fedq00"
docker exec -i rabbit-north rabbitmqadmin delete queue name="q1"
