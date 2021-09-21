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

The first thing to do is setting up DHCP. 

Do this with `dhclient &`

Next is resizing the filesystem:

*This guide is for a FS resized to 5GB*

```
root@ubuntu:~# fdisk /dev/vda

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

GPT PMBR size mismatch (4612095 != 10485759) will be corrected by write.
The backup GPT table is not on the end of the device. This problem will be corrected by write.

Command (m for help): p

Disk /dev/vda: 5 GiB, 5368709120 bytes, 10485760 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 0FC6D41E-63DA-45DC-A0C5-EBB798E72BBA

Device      Start     End Sectors  Size Type
/dev/vda1  227328 4612062 4384735  2.1G Linux filesystem
/dev/vda14   2048   10239    8192    4M BIOS boot
/dev/vda15  10240  227327  217088  106M EFI System

Partition table entries are not in disk order.

Command (m for help): d
Partition number (1,14,15, default 15): 1

Partition 1 has been deleted.

Command (m for help): n
Partition number (1-13,16-128, default 1): 
First sector (34-10485726, default 227328): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (227328-10485726, default 10485726): 

Created a new partition 1 of type 'Linux filesystem' and of size 4.9 GiB.
Partition #1 contains a ext4 signature.

Do you want to remove the signature? [Y]es/[N]o: Y

The signature will be removed by a write command.

Command (m for help): w

The partition table has been altered.
Syncing disks.

root@ubuntu:~# reboot

....

root@ubuntu:~# resize2fs /dev/vda1
resize2fs 1.45.5 (07-Jan-2020)
Filesystem at /dev/vda1 is mounted on /; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 1
The filesystem on /dev/vda1 is now 1282299 (4k) blocks long.

root@ubuntu:~# df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            2.0G     0  2.0G   0% /dev
tmpfs           394M  768K  393M   1% /run
/dev/vda1       4.7G  1.7G  3.1G  35% /
tmpfs           2.0G     0  2.0G   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           2.0G     0  2.0G   0% /sys/fs/cgroup
/dev/loop0       56M   56M     0 100% /snap/core18/2128
/dev/loop1       71M   71M     0 100% /snap/lxd/21029
/dev/loop2       33M   33M     0 100% /snap/snapd/12883
/dev/vda15      105M  5.2M  100M   5% /boot/efi
tmpfs           394M     0  394M   0% /run/user/0
```

Next, copy and paste the [install-ndn-dpdk.sh](https://github.com/cbmckni/ndn-dpdk-k8s/blob/master/vm/install-ndn-dpdk.sh) script into the VM, then run it.

That will install all the NDN-DPDK dependencies and any other software you wish to add.

After the script has finished, exit the VM and stop it with `shutdown -h now`.

You should now have a stopped VM and the file `ndn-dpdk.img` in your current directory.

To copy the file into a docker container, build the [Dockerfile](): `docker build -t <user-name>/ndn-dpdk-disk .`

Once the container is built, upload it to DockerHub:

`docker login`

`docker push <user-name>/ndn-dpdk-disk`

Now your NDN-DPDK container disk can be pulled and deployed!

### Clean Up

To clean up everything, use the script [clean-up.sh](https://github.com/cbmckni/ndn-dpdk-k8s/blob/master/vm/clean-up.sh).

**This will delete the VM and the .img file. Make sure all progress has been pushed to DockerHub!**

