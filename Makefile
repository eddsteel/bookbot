VERSION:=$(shell git rev-parse HEAD | cut -c1-7)

books:
	./scripts/spider-notebook.sh

login:
	$$(aws ecr get-login --no-include-email)

image:
	docker pull $(DOCKER_REPO)/$(DOCKER_REPO_IMG)-dep:latest || true
	docker build --target dependencies --cache-from $(DOCKER_IMG)-dep:latest --tag $(DOCKER_IMG)-dep .
	docker build --target app --cache-from $(DOCKER_IMG)-dep:latest --tag $(DOCKER_IMG) .
	docker tag $(DOCKER_IMG):latest $(DOCKER_IMG):$(VERSION)

tag:
	docker tag $(DOCKER_IMG):latest $(DOCKER_REPO)/$(DOCKER_REPO_IMG):latest
	docker tag $(DOCKER_IMG)-dep:latest $(DOCKER_REPO)/$(DOCKER_REPO_IMG)-dep:latest
	docker tag $(DOCKER_IMG):latest $(DOCKER_REPO)/$(DOCKER_REPO_IMG):$(VERSION)

push:
	docker push $(DOCKER_REPO)/$(DOCKER_REPO_IMG):latest
	docker push $(DOCKER_REPO)/$(DOCKER_REPO_IMG):$(VERSION)
	docker push $(DOCKER_REPO)/$(DOCKER_REPO_IMG)-dep:latest

run:
	docker run \
	    -e OAUTH_CONSUMER_KEY -e OAUTH_CONSUMER_SECRET -e OAUTH_ACCESS_TOKEN \
	    -e OAUTH_ACCESS_SECRET -e BOOK_DIRECTORY -e S3_BUCKET -e S3_URL \
	    $(DOCKER_IMG):latest

deploy: books login image tag push