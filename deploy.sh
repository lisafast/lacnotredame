#!/bin/sh
USER=xxx
HOST=xxx.ca
DIR=sites/???/   # linked on server to real web site published site

rsync -avzu --delete public/ ${USER}@${HOST}:~/${DIR}

exit 0