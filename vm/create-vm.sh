#!/bin/bash

# Usage: ./create-vm.sh <default-password>

if [ $# -eq 0 ]; then
    echo "Usage: ./create-vm.sh <default-password>"
    exit 1
fi

wget -O ndn-dpdk.img https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img

qemu-img resize ndn-dpdk.img 3G

virt-customize -a ndn-dpdk.img  --root-password password:$1

PWD=$(pwd)

cat > vm.xml <<EOF
<domain type='kvm'>
  <name>ndndpdk</name>
  <memory unit='GiB'>4</memory>
  <currentMemory unit='GiB'>4</currentMemory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64'>hvm</type>
    <boot dev='hd'/>
  </os>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <devices>
    <emulator>/usr/libexec/qemu-kvm</emulator>
  <disk type='file' device='disk'>
       <driver name='qemu' type='qcow2'/>
       <source file='${PWD}/ndn-dpdk.img'/>
       <target dev='vda' bus='virtio'/>
  </disk>
  <interface type='bridge'>
    <source bridge='virbr0'/>
    <model type='virtio'/>
  </interface>
  <serial type='pty'>
    <target port='0'/>
  </serial>
  <console type='pty'>
    <target type='serial' port='0'/>
  </console>
  </devices>
</domain>
EOF

virsh define vm.xml

#Copy ndn-dpdk binaries
docker run cbmckni/ndn-dpdk-builder:latest &
sleep 5
ID=$(docker container ls | grep cbmckni/ndn-dpdk-builder:latest | awk '{ print $1 }')
docker cp ${ID}:/usr/local local
virt-copy-in -a ndn-dpdk.img ./local /usr

virsh start ndndpdk

echo "Done! Run 'virsh console ndndpdk' to access VM. "

