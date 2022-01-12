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

`./deploy.sh <node-list-file> <testbed-name>`

View the deployed VMs with `kubectl get vms`.

View the services with `kubectl get svc`

To expose a node to the public internet, run:

`virtctl expose virtualmachineinstance <vm-name> --name <service-name> --type NodePort --port 63636 --target-port 6363 --node-port 63636`

Get a console to a VM with

`virtctl console <vm-name>` 

## Clean Up

To destroy a testbed, simply run:

`./clean-up-testbed.sh <node-list-file> <testbed-name>`
