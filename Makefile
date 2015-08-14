# Configuration parameters
TOKEN=`head -c 30 /dev/urandom | xxd -p`

notebook-image: Dockerfile
	docker build -t dietmarw/notebook .

images: notebook-image

proxy-image:
	docker pull jupyter/configurable-http-proxy

proxy: proxy-image
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) \
		--name=proxy jupyter/configurable-http-proxy \
		--default-target http://127.0.0.1:9999

notebook: notebook-image
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) \
		--name=tmpnb \
		-v /var/run/docker.sock:/docker.sock jupyter/tmpnb python orchestrate.py \
		--image=dietmarw/notebook

dev: clean proxy notebook

stop:
	-docker stop `docker ps -q`

restart:
	-docker restart `docker ps -q`

clean:
	-docker rm  -f  `docker ps -aq`

distclean: clean
	-docker images -q --filter "dangling=true" | xargs docker rmi

log-tmpnb:
	docker logs -f tmpnb

log-proxy:
	docker logs -f proxy

.PHONY: cleanup
