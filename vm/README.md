# NDN-DPDK VM Orchestration with KubeVirt 

This is a collection of tools for orchestrating NDN-DPDK VMs on Kubernetes. 

Installing dependencies, building, and deploying the VMs will be covered.

## Installation

First, install dependencies:
 - [kubectl](https://kubernetes.io/docs/tasks/tools/)
 - [virtctl](https://kubevirt.io/user-guide/operations/virtctl_client_tool/)
 - [kvm](https://www.tecmint.com/install-kvm-on-ubuntu/)
*Some tools may be missing. A simple search will reveal installation docs for missing tools.*

Make sure kubectl is configured properly with the Kubernetes cluster of your choosing.

## Deploy NDN-DPDK VM

To deploy a VM to a Kubernetes cluster using KubeVirt:

List running VMs: `kubectl get vms`

Edit the [ndn-dpdk-vm.yaml](https://github.com/cbmckni/ndn-dpdk-k8s/blob/master/vm/ndn-dpdk-vm.yaml) file if needed.

If there is already a vm with the name `ndndpdkvm`, change the `name:` and `kubevirt.io/domain:` fields to something unique.

Deploy the VM: `kubectl create -f ndn-dpdk-vm.yaml`

Start the VM: `virtctl start <vm-name>`

Get a console: `virtctl console <vm-name>`

Use the default password set for the VM with login `root`.

### Clean Up

Stop VM with: `virtctl stop <vm-name>`

Delete VM with: `kubectl delete -f ndn-dpdk-vm.yaml`

## Build NDN-DPDK VM

To add software to the ContainerDisk, a new build must be done. 

First, run the script [create-vm.sh](https://github.com/cbmckni/ndn-dpdk-k8s/blob/master/vm/create-vm.sh) with your desired default root password: `./create-vm <password>`

*The default password may be specified at deployment using UserData.*

This script does the following:

 - Downloads the Ubuntu 20.04 cloud image.
 - Sets the default root password for the image.
 - Creates a VM definition XML file.
 - Runs the builder docker container.
 - Copies the pre-built NDN-DPDK binaries in the container locally, then into the VM.
 - Starts the VM.

After the script has finished, run `virsh console ndndpdk` to access the VM. 

Use the login `root` and the password you specified.

After you get a console, copy and paste the [install-ndn-dpdk.sh](https://github.com/cbmckni/ndn-dpdk-k8s/blob/master/vm/install-ndn-dpdk.sh) script into the VM, then run it.

That will install all the NDN-DPDK dependencies and any other software you wish to add.

After the script has finished, exit the VM and stop it with `virsh stop ndndpdk`.

You should now have a stopped VM and the file `ndn-dpdk.img` in your current directory.

To copy the file into a docker container, build the [Dockerfile](): `docker build -t <user-name>/ndn-dpdk-disk .`

Once the container is built, upload it to DockerHub:

`docker login`

`docker push <user-name>/ndn-dpdk-disk`

Now your NDN-DPDK container disk can be pulled and deployed!

### Clean Up

To clean up everything, use the script [clean-up.sh](https://github.com/cbmckni/ndn-dpdk-k8s/blob/master/vm/clean-up.sh).

**This will delete the VM and the .img file. Make sure all progress has been pushed to DockerHub!**

