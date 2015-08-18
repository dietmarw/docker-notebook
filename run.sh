#!/bin/bash
TOKEN=`head -c 30 /dev/urandom | xxd -p`

docker rm  -f  `docker ps -aq`

docker pull dietmarw/notebook

docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$TOKEN \
       --name=proxy jupyter/configurable-http-proxy \
       --default-target http://127.0.0.1:9999

docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$TOKEN \
       --name=tmpnb \
       -v /var/run/docker.sock:/docker.sock jupyter/tmpnb python orchestrate.py \
       --image=dietmarw/notebook \
       --command="setup.sh && \
                  ipython notebook --NotebookApp.base_url={base_path} --ip=0.0.0.0 --port {port}" \
       --redirect_uri="terminals/1" \
       --pool_size="2"

# This adds a reroute to port 80 (needs root privileges)
# the IP is for now set for the current droplet
iptables -t nat -I PREROUTING -p tcp -d 188.226.207.162 --dport 80 -j REDIRECT --to-ports 8000
iptables -t nat -I OUTPUT -p tcp -o lo --dport 80 -j REDIRECT --to-ports 8000
