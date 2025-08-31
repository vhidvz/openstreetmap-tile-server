.PHONY: build push test

DB_IMAGE=wenex/osm-db
TILE_IMAGE=wenex/osm-tileserver

build:
	docker build -t ${DB_IMAGE} -f Dockerfile.db .
	docker build -t ${TILE_IMAGE} -f Dockerfile.tileserver .

push: build
	docker push ${DOCKER_IMAGE}:latest

test: build
	docker volume create osm-data
	docker run --rm -v osm-data:/data/database/ ${DOCKER_IMAGE} import
	docker run --rm -v osm-data:/data/database/ -p 8080:80 -d ${DOCKER_IMAGE} run

stop:
	docker rm -f `docker ps | grep '${DOCKER_IMAGE}' | awk '{ print $$1 }'` || true
	docker volume rm -f osm-data
