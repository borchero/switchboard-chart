KIND_CLUSTER_NAME ?= switchboard-chart-tests

#--------------------------------------------------------------------------------------------------
# TESTING
#--------------------------------------------------------------------------------------------------
e2e-tests: create-cluster
	bats $(CURDIR)/tests -t

#--------------------------------------------------------------------------------------------------
# CLUSTER PROVISIONING
#--------------------------------------------------------------------------------------------------
create-cluster:
	kind get clusters | grep -q "^${KIND_CLUSTER_NAME}$$" || \
	kind create cluster \
	--name ${KIND_CLUSTER_NAME} \
	--config $(CURDIR)/tests/kind/config.yaml
	kubectl config use-context kind-${KIND_CLUSTER_NAME}

teardown-cluster:
	kind delete cluster --name ${KIND_CLUSTER_NAME} || :
