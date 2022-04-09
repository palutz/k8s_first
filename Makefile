#!/usr/bin/env make

run_website:
	docker build -t firstnginx01 .  
	docker run -d -p 5000:80 -h= firstnginx01

stop_website:
	docker stop $(docker ps -q --filter ancestor= firstnginx01)

install_kind:
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.12.0/kind-darwin-amd64
	chmod +x ./kind

install_kubectl:
	brew install kubectl

create_kind_cluster: install_kind install_kubectl create_docker_registry
	kind create cluster --name firstnginx01
	kubectl get nodes

create_docker_registry: 
	docker run --name local-registry -d --restart=always -p 5000:5000 registry:2
