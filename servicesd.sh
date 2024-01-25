#!/bin/bash
cd /home/ubuntu/
nohup ./sls.sh & 
disown %1
# nohup ./srtla.sh &
while true; do sleep 1; done