# NDN-DPDK on Kubernetes

This is a collection of tools for orchestrating NDN-DPDK containers on Kubernetes. For each node specifed, a Producer VM and a Forwarder VM will be deployed inside a container disk. See the `vm/` directory for more instructions.

## Deployment

First, create a list of nodes on your K8s cluster and save it to a text file:

```
$ cat nodelist.txt 
nrp-c11.nysernet.org
nrp-c13.nysernet.org
nrp-c14.nysernet.org
k8s-igrok-06.calit2.optiputer.net
k8s-igrok-07.calit2.optiputer.net
```

Next, run `deploy.sh` with that file as the argument:

`./deploy.sh nodelist.txt`

View the deployed VMs with `kubectl get vms`.













