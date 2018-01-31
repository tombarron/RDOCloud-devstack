#!/bin/bash -x

ssh -X -i ~/.ssh/id_rsa centos@{{ devstack_host_vm.server.public_v4 }}
