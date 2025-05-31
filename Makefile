# Alethic ISM Helm Makefile
# Provides utility commands for managing the Alethic ISM Kubernetes deployment

# Configuration
NAMESPACE := default
RELEASE_NAME := test-release
KIND_CLUSTER_NAME := kind
KUBE_CONTEXT := kind-$(KIND_CLUSTER_NAME)

.PHONY: help create-cluster create-cluster-ingress delete-cluster install-nginx-ingress \
        install-chart delete-chart status check-pods install-dependencies all clean \
        create-namespace delete-namespace list-resources namespace-exists port-forward \
        check-context

help:
	@echo "Alethic ISM Helm Makefile"
	@echo ""
	@echo "Configuration:"
	@echo "  NAMESPACE            = $(NAMESPACE)"
	@echo "  RELEASE_NAME         = $(RELEASE_NAME)"
	@echo "  KIND_CLUSTER_NAME    = $(KIND_CLUSTER_NAME)"
	@echo "  KUBE_CONTEXT         = $(KUBE_CONTEXT)"
	@echo ""
	@echo "Available targets:"
	@echo "  help                 - Display this help"
	@echo "  check-context        - Check and set the Kubernetes context for kind cluster"
	@echo "  create-namespace     - Create the Kubernetes namespace"
	@echo "  delete-namespace     - Delete the Kubernetes namespace"
	@echo "  namespace-exists     - Check if namespace exists"
	@echo "  create-cluster       - Create a basic kind cluster"
	@echo "  create-cluster-ingress - Create a kind cluster with ingress support"
	@echo "  delete-cluster       - Delete the kind cluster"
	@echo "  install-nginx-ingress - Install NGINX ingress controller"
	@echo "  install-chart        - Install Alethic ISM Helm chart"
	@echo "  delete-chart         - Delete Alethic ISM Helm chart"
	@echo "  status               - Check Helm release status"
	@echo "  check-pods           - Check status of all pods in the namespace"
	@echo "  install-dependencies - Install required tools (kind, kubectl, helm)"
	@echo "  list-resources       - List all resources in the namespace"
	@echo "  port-forward         - Forward ports for specific services (usage: make port-forward SVC=service-name PORT=8080)"
	@echo "  all                  - Create cluster with ingress, namespace, and install chart"
	@echo "  clean                - Delete chart, namespace, and cluster"

# Namespace operations
create-namespace:
	@echo "Creating namespace $(NAMESPACE)..."
	kubectl --context $(KUBE_CONTEXT) create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl --context $(KUBE_CONTEXT) apply -f -

delete-namespace:
	@echo "Deleting namespace $(NAMESPACE)..."
	kubectl --context $(KUBE_CONTEXT) delete namespace $(NAMESPACE) --ignore-not-found

namespace-exists:
	@kubectl --context $(KUBE_CONTEXT) get namespace $(NAMESPACE) > /dev/null 2>&1 && echo "Namespace $(NAMESPACE) exists" || echo "Namespace $(NAMESPACE) does not exist"

# Context operations
check-context:
	@kubectl config get-contexts | grep -E "^\*.*$(KUBE_CONTEXT)" > /dev/null 2>&1 && \
		echo "Context $(KUBE_CONTEXT) is active" || \
		(echo "Context $(KUBE_CONTEXT) is not active. Setting context..." && kubectl config use-context $(KUBE_CONTEXT))

# Kind cluster operations
create-cluster:
	@echo "Creating kind cluster..."
	kind create cluster --name $(KIND_CLUSTER_NAME)

create-cluster-ingress:
	@echo "Creating kind cluster with ingress support..."
	kind create cluster --name $(KIND_CLUSTER_NAME) --config=kind-config-ingress.yaml

delete-cluster:
	@echo "Deleting kind cluster..."
	kind delete cluster --name $(KIND_CLUSTER_NAME)

install-nginx-ingress:
	@echo "Installing NGINX ingress controller..."
	kubectl --context $(KUBE_CONTEXT) apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

# Helm chart operations
install-chart: create-namespace
	@echo "Installing Alethic ISM Helm chart in namespace $(NAMESPACE)..."
	helm install $(RELEASE_NAME) . --debug -n $(NAMESPACE) --kube-context $(KUBE_CONTEXT)

delete-chart:
	@echo "Deleting Alethic ISM Helm chart from namespace $(NAMESPACE)..."
	helm delete $(RELEASE_NAME) -n $(NAMESPACE) --ignore-not-found --kube-context $(KUBE_CONTEXT)

# Status and monitoring
status:
	@echo "Checking Helm release status in namespace $(NAMESPACE)..."
	helm status $(RELEASE_NAME) -n $(NAMESPACE) --kube-context $(KUBE_CONTEXT)

check-pods:
	@echo "Checking pod status in namespace $(NAMESPACE)..."
	kubectl --context $(KUBE_CONTEXT) get pods -n $(NAMESPACE)

list-resources:
	@echo "Listing all resources in namespace $(NAMESPACE)..."
	@echo "--- Deployments ---"
	kubectl --context $(KUBE_CONTEXT) get deployments -n $(NAMESPACE)
	@echo "--- Services ---"
	kubectl --context $(KUBE_CONTEXT) get services -n $(NAMESPACE)
	@echo "--- Pods ---"
	kubectl --context $(KUBE_CONTEXT) get pods -n $(NAMESPACE)
	@echo "--- ConfigMaps ---"
	kubectl --context $(KUBE_CONTEXT) get configmaps -n $(NAMESPACE)
	@echo "--- Secrets ---"
	kubectl --context $(KUBE_CONTEXT) get secrets -n $(NAMESPACE)
	@echo "--- Ingresses ---"
	kubectl --context $(KUBE_CONTEXT) get ingress -n $(NAMESPACE)

# Port forwarding
port-forward:
	@[ "${SVC}" ] || ( echo "Error: SVC parameter is required. Usage: make port-forward SVC=service-name PORT=8080"; exit 1 )
	@[ "${PORT}" ] || ( echo "Error: PORT parameter is required. Usage: make port-forward SVC=service-name PORT=8080"; exit 1 )
	@echo "Port forwarding $(SVC) on port $(PORT) in namespace $(NAMESPACE)..."
	kubectl --context $(KUBE_CONTEXT) port-forward svc/$(SVC) $(PORT):$(PORT) -n $(NAMESPACE)

# Tool installation (basic)
install-dependencies:
	@echo "This target will help install required dependencies."
	@echo "Please refer to the README.md for detailed instructions."
	@echo "Basic tools needed: Docker, kind, kubectl, Helm"

# Combined operations
all: create-cluster-ingress install-nginx-ingress create-namespace install-chart
	@echo "Cluster created and Alethic ISM chart installed in namespace $(NAMESPACE)!"

clean: delete-chart delete-namespace delete-cluster
	@echo "Chart, namespace, and cluster deleted!"