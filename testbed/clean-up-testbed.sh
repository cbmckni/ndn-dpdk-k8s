#!/bin/bash

# Usage: ./clean-up-testbed.sh <node-list-file> <testbed-name>

if [ $# -lt 2 ]; then
    echo "Usage: ./clean-up-testbed.sh <node-list-file> <testbed-name>"
    exit 1
fi

while read node; do
  N="ndn-dpdk-${node}-${2}"
  NAME="${N//./-}"
  echo "$node"
  kubectl delete -f $N.yaml
  kubectl delete svc ${NAME}-p-svc
  kubectl delete svc ${NAME}-f-svc
  kubectl delete svc ${NAME}-c-svc
  rm $N.yaml
done <$1

