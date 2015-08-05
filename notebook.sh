#!/bin/bash

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# # Create a self signed certificate for the user if one doesn't exist
# if [ ! -f $PEM_FILE ]; then
#   openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $PEM_FILE -out $PEM_FILE \
#     -subj "/C=XX/ST=XX/L=XX/O=dockergenerated/CN=dockergenerated"
# fi

HASH=$(python -c "from IPython.lib import passwd; print(passwd('${PASSWORD}'))")
unset PASSWORD

# remove any old notebook files
rm -rf /opt/notebooks/*
# Clone the notebook files
git clone https://github.com/dietmarw/EK5312_ElectricalMachines /opt/notebooks/EK5312
# make notebook files read only
chmod a-w /opt/notebooks/EK5312/Chapman/*.ipynb

# Use this version for running the server secure via https
# ipython notebook --no-browser --port 8888 --ip=* --certfile=$PEM_FILE --NotebookApp.password="$HASH"

# Use this version for running the server insecure via http
ipython notebook --no-browser --port 8888 --ip=* --NotebookApp.password="$HASH"
