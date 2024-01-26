#!/bin/bash

# Start the first program in the background
/home/ubuntu/srt-live-server/bin/sls -c /home/ubuntu/srt-live-server/sls.conf &

# Start the second program in the background
/home/ubuntu/srtla/srtla_rec 8383 0.0.0.0 8282 &

# Keep the script running
tail -f /dev/null