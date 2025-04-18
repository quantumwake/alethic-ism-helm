# Alethic Helm Chart Deployment Guide
This guide walks through the process of setting up a local Kubernetes environment using kind, configuring local storage, and deploying the Alethic application stack using Helm.
Prerequisites

Docker
kind
kubectl
Helm

### Install Kind Cluster (MacOS)
* Create a new kind cluster and set up local storage class:
* Please refer to the kind [quick start](https://kind.sigs.k8s.io/docs/user/quick-start/) for more details and updates.

### Download the kind binary for your platform:
```shell
# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
```

```shell
# For ARM64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-arm64
```

### Ensure the downloaded file is executable:
```shell

chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### Create Kind Cluster without Ingress
```shell
kind create cluster
```

### Create Kind Cluster with Ingress (recommended)
```bash
kind create cluster --config=kind-config-ingress.yaml
```

### Install NGINX Ingress Controller (Kind Cluster)
```shell
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
```

### Delete Kind Cluster
```shell
kind delete cluster
```

### Setup Kind Local Storage Class (optional -- TODO probably not needed)
```shell
mkdir -p /tmp/kind-local-storage
```shell 
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF
```

#### Installation of Helm

#### Delete existing helm chart installation of alethic-ism

```shell
helm delete test-release
```

#### Installation of alethic-ism helm chart
```shell
helm install test-release . -debug -n alethic --create-namespace
```

#### Check the status of the helm chart
```shell
helm status test-release -n alethic
```

```shell
kubectl get pods -n alethic
```

