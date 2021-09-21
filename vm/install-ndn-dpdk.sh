#!/bin/bash

dhclient &

git clone https://github.com/usnistgov/ndn-dpdk.git

apt-get -y update && \
    apt-get -y install --no-install-recommends iproute2 jq \
      libaio1 libatomic1 libc6 libelf1 libnuma1 libpcap0.8 \
      libssl1.1 liburcu6 libuuid1 zlib1g \
      dpdk-dev libdpdk-dev iperf3 traceroute iputils-ping make && \
    rm -rf /var/lib/apt/lists/*