#!/bin/bash

# Start the first program in the background
sls -c /home/ubuntu/srt-live-server/sls.conf &

# Wait for a few seconds to ensure that sls is fully started
sleep 5

# Start the second program in the background
srtla_rec 8383 0.0.0.0 8282 &

# Keep the script running
tail -f /dev/null