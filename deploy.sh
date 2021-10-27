#!/bin/bash

while read node; do
  echo "Node: $node"
  YAML="ndn-dpdk-${node}.yaml"
  NAME="ndn-dpdk-${node}"
  cat <<EOF > "$YAML"
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: ${NAME}-producer
spec:
  running: false
  template:
    metadata:
      labels:
        kubevirt.io/size: small
        kubevirt.io/domain: ${NAME}-producer
    spec:
      nodeSelector:
        kubernetes.io/hostname: ${node}
      domain:
        devices:
          disks:
            - name: containerdisk
              disk:
                bus: virtio
            - name: cloudinitdisk
              disk:
                bus: virtio
          interfaces:
          - name: default
            masquerade: {}
        resources:
          requests:
            memory: 64M
      networks:
      - name: default
        pod: {}
      volumes:
        - name: containerdisk
          containerDisk:
            image: cbmckni/ndn-dpdk-disk
        - name: cloudinitdisk
          cloudInitNoCloud:
            userDataBase64: SGkuXG4=
---
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: ${NAME}-forwarder
spec:
  running: false
  template:
    metadata:
      labels:
        kubevirt.io/size: small
        kubevirt.io/domain: ${NAME}-forwarder
    spec:
      nodeSelector:
        kubernetes.io/hostname: ${node}
      domain:
        devices:
          disks:
            - name: containerdisk
              disk:
                bus: virtio
            - name: cloudinitdisk
              disk:
                bus: virtio
          interfaces:
          - name: default
            masquerade: {}
        resources:
          requests:
            memory: 64M
      networks:
      - name: default
        pod: {}
      volumes:
        - name: containerdisk
          containerDisk:
            image: cbmckni/ndn-dpdk-disk
        - name: cloudinitdisk
          cloudInitNoCloud:
            userDataBase64: SGkuXG4=
EOF
  kubectl create -f $YAML
  echo "VMs for node ${node} submitted."
  virtctl start $NAME-producer
  virtctl start $NAME-forwarder
  echo "VMs $NAME started."
done < $1