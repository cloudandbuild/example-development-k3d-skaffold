# ~/workspace/project/Makefile
# k3d, registry vars
CLUSTER_NAME=myk3dcluster
REGISTRY_IMAGE=registry:2
REGISTRY_HOST=registry.local
REGISTRY_PORT=5000
REGISTRY_VOLUME=local_registry_volume
DEFAULT_REPO="$(REGISTRY_HOST):$(REGISTRY_PORT)"

# for k3d cluster
.PHONY: create
create:
	k3d cluster create $(CLUSTER_NAME) \
		--volume "$(PWD)/registry/registries.yaml:/etc/rancher/k3s/registries.yaml"
	docker volume create $(REGISTRY_VOLUME)
	docker container run -d \
		--net k3d-$(CLUSTER_NAME) \
		--name $(REGISTRY_HOST) \
		-v $(REGISTRY_VOLUME):/var/lib/registry \
		--restart always \
		-p $(REGISTRY_PORT):$(REGISTRY_PORT) \
		$(REGISTRY_IMAGE)

.PHONY: start
start:
	k3d cluster start $(CLUSTER_NAME)

.PHONY: dev
dev:
	skaffold dev --port-forward --default-repo $(DEFAULT_REPO)

.PHONY: stop
stop:
	k3d cluster stop $(CLUSTER_NAME)

.PHONY: down
down: stop
	docker stop $(REGISTRY_HOST)
	docker rm $(REGISTRY_HOST)
	k3d cluster delete $(CLUSTER_NAME)