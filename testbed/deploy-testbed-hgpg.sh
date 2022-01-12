#!/bin/bash

# Usage: ./deploy-testbed.sh <node-list-file> <testbed-name>

if [ $# -lt 2 ]; then
    echo "Usage: ./deploy-testbed.sh <node-list-file> <testbed-name>"
    exit 1
fi

while read node; do
  echo "Node: $node"
  YAML="ndn-dpdk-${node}-${2}.yaml"
  N="ndn-dpdk-${node}-${2}"
  NAME="${N//./-}"
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
        testbed: ${2}
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
            memory: 8Gi
            cpu: 6
          limits:
            memory: 8Gi
            cpu: 6
        memory:
          hugepages:
            pageSize: "1Gi"
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
        testbed: ${2}
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
            memory: 8Gi
            cpu: 6
          limits:
            memory: 8Gi
            cpu: 6
        memory:
          hugepages:
            pageSize: "1Gi"
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
  name: ${NAME}-consumer
spec:
  running: false
  template:
    metadata:
      labels:
        kubevirt.io/size: small
        kubevirt.io/domain: ${NAME}-consumer
        testbed: ${2}
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
            memory: 8Gi
            cpu: 6
          limits:
            memory: 8Gi
            cpu: 6
        memory:
          hugepages:
            pageSize: "1Gi"
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
  virtctl start $NAME-consumer
  virtctl expose virtualmachineinstance $NAME-producer --name ${NAME}-p-svc --port 63636 --target-port 6363
  virtctl expose virtualmachineinstance $NAME-forwarder --name ${NAME}-f-svc --port 63636 --target-port 6363
  virtctl expose virtualmachineinstance $NAME-consumer --name ${NAME}-c-svc --port 63636 --target-port 6363

  echo "VMs for ${node} started."
done < $1
