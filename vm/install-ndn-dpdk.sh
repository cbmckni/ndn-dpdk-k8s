#!/bin/bash

dhclient &

git clone https://github.com/usnistgov/ndn-dpdk.git

apt-get -y -qq update && \
    apt-get -y -qq install --no-install-recommends iproute2 jq \
      libaio1 libatomic1 libc6 libelf1 libnuma1 libpcap0.8 \
      libssl1.1 liburcu6 libuuid1 zlib1g && \
    rm -rf /var/lib/apt/lists/*
