#!/bin/bash

sudo docker cp ~/forwarder.config.js fw:/.
sudo docker exec fw bash -c 'node forwarder.config.js | jq "." | ndndpdk-ctrl activate-forwarder'

echo "Creating faces and fib entries...."
sudo docker exec fw bash -c 'nh=$(ndndpdk-ctrl create-ether-face --local 5c:75:25:5b:d4:1e --remote 4a:b8:40:b3:f7:d6 | jq .id) && eval "ndndpdk-ctrl insert-fib --name /prefix/ping --nh $nh"'
sudo docker exec fw ndndpdk-ctrl create-ether-face --local 5c:75:25:5b:d4:1f --remote 5e:09:59:e3:b3:f7
