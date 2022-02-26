VERSION:=$(shell git rev-parse HEAD | cut -c1-7)

books:
	./scripts/spider-notebook.sh

login:
	$(shell aws ecr get-login-password | docker login --username AWS --password-stdin $(DOCKER_REPO))

image:
	nix-build --argstr tag $(VERSION) docker.nix
	docker load -i result

tag:
	docker tag $(DOCKER_IMG):$(VERSION) $(DOCKER_IMG):latest
	docker tag $(DOCKER_IMG):latest $(DOCKER_REPO)/$(DOCKER_REPO_IMG):latest
	docker tag $(DOCKER_IMG):latest $(DOCKER_REPO)/$(DOCKER_REPO_IMG):$(VERSION)

push:
	docker push $(DOCKER_REPO)/$(DOCKER_REPO_IMG):latest
	docker push $(DOCKER_REPO)/$(DOCKER_REPO_IMG):$(VERSION)

run:
	docker run --env-file .env $(DOCKER_IMG):$(VERSION)

deploy: books login image tag push
