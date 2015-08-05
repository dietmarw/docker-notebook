# Configuration parameters
TOKEN=`head -c 30 /dev/urandom | xxd -p`

notebook-image: Dockerfile
	docker build -t dietmarw/notebook .

images: notebook-image minimal-image

minimal-image:
	docker pull jupyter/minimal

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

minimal: minimal-image
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) \
		--name=tmpnb \
		-v /var/run/docker.sock:/docker.sock jupyter/tmpnb

test: clean
	docker pull dietmarw/notebook
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) \
		--name=proxy jupyter/configurable-http-proxy \
		--default-target http://127.0.0.1:9999
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) \
	       --name=tmpnb \
	       -v /var/run/docker.sock:/docker.sock jupyter/tmpnb python orchestrate.py \
	       --image=dietmarw/notebook

dev: clean proxy notebook

min: clean proxy minimal

open:
	-open http://`echo $(DOCKER_HOST) | cut -d":" -f2`:8000

clean:
#	-docker stop `docker ps -aq`
	-docker rm  -f  `docker ps -aq`

distclean: clean
	-docker images -q --filter "dangling=true" | xargs docker rmi

log-tmpnb:
	docker logs -f tmpnb

log-proxy:
	docker logs -f proxy

.PHONY: cleanup
