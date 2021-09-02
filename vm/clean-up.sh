#!/bin/bash

rm ndn-dpdk.img
rm vm.xml
virsh destroy ndndpdk
virsh undefine ndndpdk
