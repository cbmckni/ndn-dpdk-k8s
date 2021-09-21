#!/bin/bash

rm -rf ./local ndn-dpdk.img vm.xml
virsh destroy ndndpdk
virsh undefine ndndpdk
ID=$(docker container ls | grep cbmckni/ndn-dpdk-builder | awk '{ print $1 }')
docker stop $ID
docker rm $ID
