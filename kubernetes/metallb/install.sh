# Install MetalLB in normal mode
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

# Set MetalLB to Layer 2 mode
kubectl apply -f metallb-config.yaml

# Add Pool of IPs for MetalLB
kubectl apply -f ip-pool.yaml
