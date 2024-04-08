build:
	docker rmi -f aes_julia_image || true
	docker build -t aes_julia_image -f ./Dockerfile .
.PHONY: build

deploy: remove
	mkdir -p graphite
	mkdir -p grafana_config
	until \
	docker stack deploy -c docker-compose.yaml aes_julia; \
	do sleep 1; done
.PHONY: deploy

remove:
	if docker stack ls | grep -q aes_julia; then \
            docker stack rm aes_julia; \
	fi
.PHONY: remove

aes_bash:
	docker exec -it $(shell docker ps -q -f name=aes_julia_app) bash
.PHONY: worker_bash