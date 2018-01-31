=================
RDOCloud-devstack
=================

This playbook creates a nova VM in the RDOCloud and sets up
a devstack environment there with the CephNFS backend.  The
nova VM runs CentOS 7.  The playbook has been tested running on
Fedora 27 but should work on CentOS, indeed on any system that
supports recent ansible.

Prerequisites
=============

We assume that you have credentials to use RDOCloud and that
you have set them up in ${HOME}/.config/openstack/clouds.yaml
along the following lines::

$ cat ~/.config/openstack/clouds.yaml 
clouds:
    rdo-cloud:
        auth:
            auth_url: https://phx2.cloud.rdoproject.org:13000/
            project_name: <your-project-name>
            username: <your-user-name>
            password: <your-password>
        region: RegionOne
$ 

The ansible playbook needs the shade library.  We don't have that
packaged for CentOS so install that in a virtualenv
and run the playbook after activating the virtualenv::

$ virtualenv venv
New python executable in ...
Also creating executable in ...
Installing setuptools, pip, wheel...done.
$ source venv/bin/activate
(venv) $ pip install shade
...

We install and activate this virtualenv in the same directory as the ansible
playbook.

Before you run the playbook edit copy keys.yml.sample to keys.yml and
edit the latter with the paths to your public and private ssh keys:: 

(venv) $ cat keys.yml.sample
---
# Set the name of the key known to the OpenStack cloud.
key_name: devstack_keypair
# Set the name of the local private key file associated
# with the named key.
private_key_file: "/path/to/your/private/key"
public_key_file: "/path/to/your/public/key"


Playbooks
=========

Now you can run the playbook::

(venv) $ ansible-playbook devstack-setup.yml

The playbook will set up an appropriate security group, keypair, and private
network, as well as a cinder volume to hold your development files and a router
to connect the private network to the RDOCloud public network.  It boots up the
Nova VM that will host the devstack environment using these.  We will refer to
this Nova VM as the "host VM" henceforth in order not to confuse it with
Nova VMs that you may launch inside devstack itself.  We are building the
host VM using openstack in RDOCloud but once built we can pretty much
forget about that and treat it as if it were a physical machine on a network or
a virtual machine on one's laptop.

The cinder volume created for the host VM will be used to hold your
development files (e.g. /opt/stack/manila).  devstack environments are notoriously
unstable and tearing down a stack and re-stacking often fails to produce a working
environment.  The cinder volume provides a good way to persist your work if you
need to destroy and rebuild the host VM.

The playbook will install a stack user and /home/stack/devstack, as well as
a version of /home/stack/devstack/local.conf suitable for stacking with the
cephNFS back end.

It does not actually run devstack since you may want to customize local.conf, etc.

The playbook writes a login.sh file in the current directory that you may use
to login to your devstack host VM.  There you can customize local.conf, run stack.sh,
and develop as normal.

To destroy your devstack host VM and start over again just run

(venv) $ ansible-playbook destroy.yml


