#!/bin/bash
cd /home/ubuntu/
./sls.sh &
./srtla.sh &
while true; do sleep 1; done