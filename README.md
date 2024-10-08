# spinkube-max-arsene

## Create infrastructure

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)

Change the name of the network used by the instances in the `terraform/ressources/variables.tf` file.

### Terraform

```bash
cd terraform
terraform init
terraform apply
```

### LoadBalancer

#### MetalLB

```bash
cd kubernetes/metallb
./install.sh
```

You need to run install.sh script on the node. Please check if Ip Pool created by Kind is the same as in the metallb-config.yaml file.

```bash
docker network inspect -f '{{.IPAM.Config}}' kind
```

### Service

```bash
kubectl apply -f kubernetes/resources/loadbalancer.yaml
```

Check if the LoadBalancer has received an IP address.

```bash
kubectl get svc
```

### HAProxy

The IP address of the LoadBalancer is used is only available on the host machine. You can use HAProxy to expose the LoadBalancer to the outside.

Install HA et config la redirect de chatgpt

```bash

```

## Scale on Rabbit messages

This demo showcase the ability to scale a deployment based on the number of messages in a RabbitMQ queue.
The deployment contains a RabbitMQ consumer and a producer. We will see how to scale the consumer based on the number of messages in the queue.

### Set-up the cluster

#### Install RabbitMQ via Helm

Since the Helm stable repository was migrated to the [Bitnami Repository](https://github.com/helm/charts/tree/master/stable/rabbitmq), add the Bitnami repo and use it during the installation:

```cli
helm repo add bitnami https://charts.bitnami.com/bitnami
```

##### Helm 3

RabbitMQ Helm Chart version 7.0.0 or later

```cli
helm install rabbitmq --set auth.username=user --set auth.password=PASSWORD bitnami/rabbitmq --wait
```

#### Wait for RabbitMQ to Deploy

⚠️ Be sure to wait until the deployment has completed before continuing. ⚠️

```cli
kubectl get po

NAME         READY   STATUS    RESTARTS   AGE
rabbitmq-0   1/1     Running   0          3m3s
```

### Deploy a consumer

```bash
kubectl apply -f deploy/deploy-consumer.yaml
```

Validate the consumer has deployed

```bash
kubectl get deploy
```

You should see rabbitmq-consumer deployment with 0 pods as there currently aren't any queue messages and for that reason it is scaled to zero.

```bash
NAME                DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
rabbitmq-consumer   0         0         0            0           3s
```

This consumer is set to consume one message per instance, sleep for 1 second, and then acknowledge completion of the message. This is used to simulate work. The ScaledObject included in the above deployment is set to scale to a minimum of 0 replicas on no events, and up to a maximum of 30 replicas on heavy events (optimizing for a queue length of 5 message per replica). After 30 seconds of no events the replicas will be scaled down (cooldown period). These settings can be changed on the ScaledObject as needed.

## Publishing messages to the queue

### Deploy the publisher job

The following job will publish 300 messages to the "hello" queue the deployment is listening to. As the queue builds up, KEDA will help the horizontal pod autoscaler add more and more pods until the queue is drained after about 2 minutes and up to 30 concurrent pods. You can modify the exact number of published messages in the deploy-publisher-job.yaml file.

```bash
kubectl apply -f deploy/deploy-publisher-job.yaml
```

Validate the deployment scales

```bash
kubectl get deploy -w
```

You can watch the pods spin up and start to process queue messages. As the message length continues to increase, more pods will be pro-actively added.

You can see the number of messages vs the target per pod as well:

```bash
kubectl get hpa
```

After the queue is empty and the specified cooldown period (a property of the ScaledObject, default of 300 seconds) the last replica will scale back down to zero.
