# Autoscale Kubernetes pods based on Ingress requests

```bash
kubectl create namespace ingress-nginx

helm install ingress-nginx ingress-nginx \
--repo https://kubernetes.github.io/ingress-nginx \
--namespace ingress-nginx \
--set controller.metrics.enabled=true \
--set-string controller.podAnnotations."prometheus\.io/scrape"="true" \
--set-string controller.podAnnotations."prometheus\.io/port"="10254"
```

```bash
kubectl create ns prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --namespace prometheus
helm upgrade --install prometheus prometheus-community/prometheus -n prometheus
```

```bash
kubectl apply -f resources
```


# Testing with Minikube

```bash
minikube addons enable ingress
minikube addons enable ingress-dns
```

# Deploy the files

```bash
kubectl apply -k ./hello-world
```


```bash
curl http://hello.p.cloudacode.com/v2
Hello, world!
Version: 2.0.0
Hostname: hello-world-two-8fbc67f6b-q8kpj
❯ curl http://hello.p.cloudacode.com/v1
Hello, world!
Version: 1.0.0
Hostname: hello-world-one-66c6b597f9-bmfpc
```

## Apply the Keda operator in the namespace

```bash
kaf http/keda/keda-v2-ingress-requests.yml -n hello-world
```