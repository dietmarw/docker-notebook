# Configuration parameters
TOKEN=`head -c 30 /dev/urandom | xxd -p`

copycerts:
	cp -L /etc/letsencrypt/live/jupyter.dwe.no/fullchain.pem .
	cp -L /etc/letsencrypt/live/jupyter.dwe.no/privkey.pem .

image: copycerts Dockerfile setup.sh
	docker build -t dietmarw/notebook .

proxy-image:
	docker pull jupyter/configurable-http-proxy

proxy: proxy-image
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) \
		--name=proxy jupyter/configurable-http-proxy \
		--default-target http://127.0.0.1:9999
tmpnb: image
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) \
		--name=tmpnb \
		-v /var/run/docker.sock:/docker.sock jupyter/tmpnb python orchestrate.py \
		--image=dietmarw/notebook

single: image
	docker run --net=host -d -e PASSWORD=$(PASSWORD) --name single dietmarw/notebook

server: single
# This adds a reroute to port 80 (needs root privileges)
# the IP is for now set for the current droplet
	sh -c "iptables -t nat -I PREROUTING -p tcp -d 128.39.88.61 --dport 80 -j REDIRECT --to-port 8888"
	sh -c "iptables -t nat -I OUTPUT -p tcp -o lo --dport 80 -j REDIRECT --to-port 8888"

dev: clean proxy notebook

stop:
	-docker stop `docker ps -q`

restart:
	-docker restart `docker ps -q`

clean:
	-docker rm  -f  `docker ps -aq`
	-rm *.pem

distclean: clean
	-docker images -q --filter "dangling=true" | xargs docker rmi

log-single:
	docker logs -f single

log-tmpnb:
	docker logs -f tmpnb

log-proxy:
	docker logs -f proxy

.PHONY: clean distclean restart stop server
