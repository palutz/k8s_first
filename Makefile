#!/usr/bin/env make

.PHONY: run_website stop_website install_kind install_kubectl create_kind_cluster create_docker_registry connect_registry_to_kind_network connect_registry_to_kind create_kind_cluster_with_registry delete_kind_cluster delete_docker_registry

run_website:
	docker build -t firstnginx01 .  
	docker run --rm -d -p 3000:80 -h= firstnginx01

stop_website:
	$(eval imageToStop = $(shell (docker ps -q -f ancestor=firstnginx01)))
	@echo $(imageToStop)
	docker stop $(imageToStop)

install_kind:
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.12.0/kind-darwin-amd64; \
	chmod +x ./kind

install_kubectl:
	brew install kubectl

create_kind_cluster: install_kind install_kubectl create_docker_registry
	./kind create cluster --name firstnginx01 --config ./kind_config.yaml || true
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
	./kind delete clusters firstnginx01

delete_docker_registry:
	docker stop local-registry && docker rm local-registry

