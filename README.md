# Alethic ISM Helm Chart

This repository contains Helm charts for deploying the Alethic Intelligent State Management (ISM) system to Kubernetes.

## Prerequisites

- Docker
- kind (Kubernetes in Docker)
- kubectl
- Helm

## Quick Start

The included Makefile provides convenient commands for the entire deployment workflow:

```bash
# View all available commands
make help

# Create a cluster, install Nginx ingress, and deploy the application
make all

# Check deployment status
make check-pods

# Clean up everything
make clean
```

## Installation Steps

### 1. Set Up Kind Cluster

Choose one of the following options:

```bash
# Basic cluster
make create-cluster

# Cluster with ingress support (recommended)
make create-cluster-ingress
make install-nginx-ingress
```

### 2. Deploy Alethic ISM

```bash
# Update dependencies
helm dependency build

# Create namespace and deploy
make install-chart

# Check deployment status
make status
make check-pods
```

### 3. Access the Application

If using ingress, access the application via configured host names.

For direct service access:
```bash
# Forward ports for a specific service
make port-forward SVC=alethic-ism-ui PORT=8080
```

## Configuration

The deployment can be customized by modifying values in:
- `values.yaml` (root chart)
- Individual subchart values in their respective directories

## Subcharts

This Helm chart includes the following components:
- alethic-ism-api: API service
- alethic-ism-monitor: Monitoring service
- alethic-ism-processor-anthropic: Anthropic processor
- alethic-ism-processor-openai: OpenAI processor
- alethic-ism-state-router: State routing service
- alethic-ism-state-sync-store: State synchronization service
- alethic-ism-ui: User interface
- alethic-ism-usage: Usage tracking service

## Troubleshooting

### Common Issues

1. **Pods in Pending State**
   - Check for resource constraints: `kubectl describe pod <pod-name> -n <namespace>`
   - Ensure your cluster has sufficient resources

2. **Service Connection Issues**
   - Verify services are running: `make check-pods`
   - Check service endpoints: `kubectl get endpoints -n <namespace>`
   - For ingress issues: `kubectl get ingress -n <namespace>` and check ingress controller logs

3. **Permission Issues**
   - Ensure secrets are correctly configured
   - Check for RBAC issues if using custom service accounts

### Debugging Commands

```bash
# Get detailed information about a pod
kubectl describe pod <pod-name> -n <namespace>

# View pod logs
kubectl logs <pod-name> -n <namespace>

# List all resources in the namespace
make list-resources

# Check if namespace exists
make namespace-exists
```

## Uninstalling

```bash
# Remove the Helm release
make delete-chart

# Delete the namespace
make delete-namespace

# Delete the cluster
make delete-cluster

# Complete cleanup
make clean
```

## License

Alethic Instruction State Machine (ISM) falls under a dual licensing model:

1. **Open Source License**: AGPLv3 for open source usage
2. **Commercial License**: Available for proprietary, closed-source usage

For full license details, please see the [LICENSE.md](LICENSE.md) file.

For commercial licensing inquiries:
- **Email:** [licensing@quantumwake.io](mailto:licensing@quantumwake.io)
- **Website:** [https://quantumwake.io](https://quantumwake.io)