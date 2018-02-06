#!/bin/bash -x

ssh -X \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -i ~/.ssh/id_rsa centos@{{ devstack_host_vm.server.public_v4 }}
