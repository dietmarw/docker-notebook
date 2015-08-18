#!/bin/bash

# Strict mode
set -euo pipefail
IFS=$'\n\t'

docker rm  -f  `docker ps -aq`

#docker pull dietmarw/notebook

PASSWORD=$1

HASH=$(python -c "from notebook.auth import passwd; print(passwd('${PASSWORD}'))")
unset PASSWORD
echo $HASH

#docker run --net=host -d --name notebook-single dietmarw/notebook-single \
#      ipython notebook --no-browser --port=8888 --NotebookApp.password="${HASH}"

docker run --net=host -d --name notebook-single jupyter/notebook \
      jupyter notebook --no-browser


# This adds a reroute to port 80 (needs root privileges)
# the IP is for now set for the current droplet
iptables -t nat -I PREROUTING -p tcp -d 188.226.207.162 --dport 80 -j REDIRECT --to-ports 8888
iptables -t nat -I OUTPUT -p tcp -o lo --dport 80 -j REDIRECT --to-ports 8000
