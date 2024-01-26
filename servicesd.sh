#!/bin/bash

cd ./home/ubuntu/srt-live-server/bin/
./sls -c ../sls.conf

# cd /home/ubuntu/srtla
# ./srtla_rec 8383 0.0.0.0 8282 &
wait -n
exit $?