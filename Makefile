# Alethic ISM Helm Makefile
# Provides utility commands for managing the Alethic ISM Kubernetes deployment

# Configuration
NAMESPACE := default
RELEASE_NAME := test-release
KIND_CLUSTER_NAME := kind
KUBE_CONTEXT := kind-$(KIND_CLUSTER_NAME)

# Optional MITM certificate configuration
# Set MITM_CERT_PATH to the path of your certificate file
# Example: make create-cluster-cert MITM_CERT_PATH=/path/to/cert.crt
MITM_CERT_PATH ?=
MITM_CERT_NAME ?= mitm-proxy-cert.crt

.PHONY: help create-cluster create-cluster-ingress delete-cluster install-nginx-ingress \
        install-chart delete-chart status check-pods install-dependencies all clean \
        create-namespace delete-namespace list-resources namespace-exists port-forward \
        check-context create-cluster-cert create-cluster-ingress-cert inject-cert

help:
	@echo "Alethic ISM Helm Makefile"
	@echo ""
	@echo "Configuration:"
	@echo "  NAMESPACE            = $(NAMESPACE)"
	@echo "  RELEASE_NAME         = $(RELEASE_NAME)"
	@echo "  KIND_CLUSTER_NAME    = $(KIND_CLUSTER_NAME)"
	@echo "  KUBE_CONTEXT         = $(KUBE_CONTEXT)"
	@echo "  MITM_CERT_PATH       = $(MITM_CERT_PATH) (optional)"
	@echo ""
	@echo "Available targets:"
	@echo "  help                 - Display this help"
	@echo "  check-context        - Check and set the Kubernetes context for kind cluster"
	@echo "  create-namespace     - Create the Kubernetes namespace"
	@echo "  delete-namespace     - Delete the Kubernetes namespace"
	@echo "  namespace-exists     - Check if namespace exists"
	@echo "  create-cluster       - Create a basic kind cluster"
	@echo "  create-cluster-cert  - Create cluster and inject MITM cert (use MITM_CERT_PATH=/path/to/cert)"
	@echo "  create-cluster-ingress - Create a kind cluster with ingress support"
	@echo "  create-cluster-ingress-cert - Create cluster with ingress and inject MITM cert"
	@echo "  inject-cert          - Inject MITM certificate into existing cluster nodes"
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
	@echo ""
	@echo "MITM Certificate Usage Examples:"
	@echo "  make create-cluster-cert MITM_CERT_PATH=/path/to/proxy-cert.crt"
	@echo "  make create-cluster-ingress-cert MITM_CERT_PATH=/path/to/proxy-cert.crt"
	@echo "  make inject-cert MITM_CERT_PATH=/path/to/proxy-cert.crt  # For existing clusters"

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

create-cluster-cert: create-cluster
	@if [ -n "$(MITM_CERT_PATH)" ]; then \
		echo "Injecting MITM certificate into kind cluster..."; \
		$(MAKE) inject-cert; \
	else \
		echo "No MITM_CERT_PATH specified. Cluster created without certificate injection."; \
	fi

create-cluster-ingress-cert: create-cluster-ingress
	@if [ -n "$(MITM_CERT_PATH)" ]; then \
		echo "Injecting MITM certificate into kind cluster with ingress..."; \
		$(MAKE) inject-cert; \
	else \
		echo "No MITM_CERT_PATH specified. Cluster created without certificate injection."; \
	fi

inject-cert:
	@if [ -z "$(MITM_CERT_PATH)" ]; then \
		echo "Error: MITM_CERT_PATH is not set. Usage: make inject-cert MITM_CERT_PATH=/path/to/cert.crt"; \
		exit 1; \
	fi
	@if [ ! -f "$(MITM_CERT_PATH)" ]; then \
		echo "Error: Certificate file not found at $(MITM_CERT_PATH)"; \
		exit 1; \
	fi
	@echo "Injecting certificate from $(MITM_CERT_PATH) into all nodes..."
	@for node in $$(kind get nodes --name $(KIND_CLUSTER_NAME)); do \
		echo "Copying certificate to node: $$node"; \
		docker cp "$(MITM_CERT_PATH)" "$$node:/usr/local/share/ca-certificates/$(MITM_CERT_NAME)"; \
		echo "Updating CA certificates on node: $$node"; \
		docker exec "$$node" update-ca-certificates; \
		echo "Restarting containerd on node: $$node"; \
		docker exec "$$node" systemctl restart containerd; \
	done
	@echo "Certificate injection completed. You may need to restart pods for changes to take effect."

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