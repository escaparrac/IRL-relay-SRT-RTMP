#!/bin/bash
cd /home/ubuntu/
nohup ./sls.sh &
nohup ./srtla.sh &
while true; do sleep 1; done