# NDN-DPDK on Kubernetes

This is a collection of tools for orchestrating NDN-DPDK containers on Kubernetes. 

The basic workflow:

0. Update NDN-DPDK by doing a [build](https://github.com/cbmckni/ndn-dpdk-k8s/tree/master/vm). Here is an video of the process [VM build](https://ensemble.clemson.edu/Watch/Ds8x9C4P). (optional) 

Build docs are found in the [vm/](https://github.com/cbmckni/ndn-dpdk-k8s/tree/master/vm) folder.

1. Create and [prime](https://github.com/cbmckni/icn-primer) PVC(s) with data to be published.

The [ICN Primer](https://github.com/cbmckni/icn-primer) is a Kubernetes StatefulSet designed to aid in creating and populating PVCs.

2. Deploy the [testbed](https://github.com/cbmckni/ndn-dpdk-k8s/tree/master/testbed) or deploy VMs [manually](https://github.com/cbmckni/ndn-dpdk-k8s/tree/master/vm).

Deployment docs for the testbed are found in the [testbed/](https://github.com/cbmckni/ndn-dpdk-k8s/tree/master/testbed) folder.

Manual deployment docs are found in the [vm/](https://github.com/cbmckni/ndn-dpdk-k8s/tree/master/vm) folder.
















