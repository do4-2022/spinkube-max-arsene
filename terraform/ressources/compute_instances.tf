resource "openstack_compute_instance_v2" "instance" {
    name          = "k3s-spinkube"
    image_id    = "dadfa4df-f30e-4578-9104-0801ebbeca9f"
    flavor_name   = "m1.large"
    key_pair      = "spinkube-keypair"
    security_groups = ["spinkube_secgroup"]
    network {
        name = var.private_network_name
    }
    user_data = <<-EOF
 #!/bin/bash

    # Install DOcker

    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    newgrp docker

    # Install kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl

    # Install Kind
    [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
    sudo mv ./kind /usr/local/bin/kind
    sudo chmod 777 /usr/local/bin/kind 
    kind create cluster


    # Install helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    
    # Install spin-operator CRDs

    kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.1.0/spin-operator.crds.yaml
    kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.1.0/spin-operator.runtime-class.yaml
    kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.1.0/spin-operator.shim-executor.yaml
    
    # Install cert-manager

    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.crds.yaml

    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.14.4

    # Install kwasm-operator

    helm repo add kwasm http://kwasm.sh/kwasm-operator/
    helm install \
    kwasm-operator kwasm/kwasm-operator \
    --namespace kwasm \
    --create-namespace \
    --set kwasmOperator.installerImage=ghcr.io/spinkube/containerd-shim-spin/node-installer:v0.13.1
    kubectl annotate node --all kwasm.sh/kwasm-node=true
    
    # Install spin-operator

    helm install spin-operator \
    --namespace spin-operator \
    --create-namespace \
    --version 0.1.0 \
    --wait \
    oci://ghcr.io/spinkube/charts/spin-operator

    kubectl apply -f https://raw.githubusercontent.com/spinkube/spin-operator/main/config/samples/simple.yaml
    
    # Add the Keda repo and the Keda HTTP trigger
    helm repo add kedacore https://kedacore.github.io/charts
    helm repo update
    helm install keda kedacore/keda --namespace --create-namespace
    helm install http-add-on kedacore/keda-add-ons-http --version 0.8.0 --namespace 
    EOF
}