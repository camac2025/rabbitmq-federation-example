This is a simple test case to set up two RMQ containers and experiment with federation.

(NB - I am new to both RMQ and docker so this may not all be optimal!)

#### Setup
* clone the repo
* docker compose will start up two RMQ4.0.6 containers with management and federation plugins configured
* the nodes have no cluster relationship and are named rmq-north (on local port 5672/15672) and rmq-south (5673/15673)
* there are 3 go binaries to generate some traffic (based on the [excellent RMQ Getting Started tutorials](https://www.rabbitmq.com/tutorials/tutorial-one-go))
  * qsender - takes a port as an argument (5672 default) and will attach, create a queue called fedq00, bind to an exchange called fedtest and start sending simple messages with a UUID payload
  * qworker - takes a port and queue name as args and will dequeue and ack the messages
  * qcleanup - takes a port as an argument (5672 default) and deletes any queues and exchanges used in the test
* there are 2 scripts to set either rmq-north or rmq-south as the federation upstream node

#### Background
I had an expectation based on various docs that if I set up some queues on rmq-north, then set north as the upstream on south, then the messages arriving at north would be replicated to south. This does not appear to happen. The only way I can get anything similar is to set *south* as the upstream of *north*, at which point the queue from north becomes visible in the south admin GUI. However, there are no messages visible.

This test case was set up to support a discussion on the [rabbitmq-users](https://groups.google.com/g/rabbitmq-users) google group.

#### Scenario 1
* Clear down any traffic and queues with worker and qcleanup
* Run set-north-upstream.sh - this will add rmq-north as an upstream for rmq-south and add a simple policy
* Confirm Federation Upstreams & Status and Policies are as expected in the Admin tab.
* Run qsender to start generating traffic (probably a good idea to run qworker 5672 fedq00 in another window)
* Confirm visible traffic in the rmq-north Overview pane
* No fedq00 or other entities are visible in rmq-south - *I WAS EXPECTING TO SEE FEDERATED MESSAGES ARRIVING HERE*
#### Scenario 2
* Clear down any traffic and queues with worker and qcleanup
* Run set-south-upstream.sh - this will add rmq-south as an upstream for rmq-north and add a simple policy
* Confirm Federation Upstreams & Status and Policies are as expected in the Admin tab.
* Run qsender to start generating traffic (probably a good idea to run qworker 5672 fedq00 in another window) - NOTE again we are sending traffic to rmq-north
* Confirm visible traffic in the rmq-north Overview pane
* NOW we can see the fedtest exchange and fedq00 queue - *I WOULD NOT EXPECT THIS AS THIS NODE IS THE UPSTREAM?!*
* We *still* however do not see any messages at rmq-south

None of this seems to match the description of operations in a whole range of docs e.g.
* https://www.rabbitmq.com/docs/federated-exchanges
* https://www.rabbitmq.com/blog/2020/07/07/disaster-recovery-and-high-availability-101
* https://stackoverflow.com/questions/57040145/configuring-federation-between-two-rabbitmq-environments-but-no-links-are-enc
