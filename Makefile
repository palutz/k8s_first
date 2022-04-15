#!/usr/bin/env make

.PHONY: run_website stop_website install_kind install_kubectl create_kind_cluster create_docker_registry connect_registry_to_kind_network connect_registry_to_kind create_kind_cluster_with_registry delete_kind_cluster delete_docker_registry

APP_NAME = firstnginx01

run_website:
	docker build -t $(APP_NAME) .  
	docker run --rm -d -p 3000:80 -h= $(APP_NAME)

stop_website:
	$(eval imageToStop = $(shell (docker ps -q -f ancestor=$(APP_NAME))))
	@echo $(imageToStop)
	docker stop $(imageToStop)

check_app:
	docker ps -f ancestor=$(APP_NAME)

install_kind:
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.12.0/kind-darwin-amd64; \
	chmod +x ./kind

install_kubectl:
	brew install kubectl

create_kind_cluster: install_kind install_kubectl create_docker_registry
	./kind create cluster --name $(APP_NAME) --config ./kind_config.yaml || true
	kubectl get nodes
	
create_docker_registry: 
	if docker ps | grep -q 'local-registry'; \
		then echo "****** Local registry already created; skipping ******"; \
		else docker run --name local-registry -d --restart=always -p 5000:5000 registry:2; \
	fi 

connect_registry_to_kind_network:
	docker network connect kind local-registry || true

connect_registry_to_kind: connect_registry_to_kind_network
	kubectl apply -f ./kind_configmap.yaml

create_kind_cluster_with_registry:
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind_network

delete_kind_cluster: delete_docker_registry
	./kind delete clusters $(APP_NAME)

delete_docker_registry:
	docker stop local-registry && docker rm local-registry

create_service_file:
	kubectl create service clusterip --dry-run=client --tcp=80:80 $(APP_NAME) --output=yaml > service.yaml

apply_service_file:
	kubectl apply -f service.yaml

list_app_services:
	kubectl get all -l app=$(APP_NAME)

