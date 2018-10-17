The aws.tf is the terraform spec to spin up the 6 ceph nodes and 1 ceph installer node (which has ssh access from outside)

The userdata.sh file contains initialization for the ceph installer node

The cnodedata.sh file contains initialization for the ceph nodes

After running:
terraform apply

The cluster gets spun up. ssh into the ceph installer node:

C:\Users\gautamnandi\terraform
λ ssh -i gnkey.pem ubuntu@18.219.80.56
Welcome to Ubuntu 16.04.5 LTS (GNU/Linux 4.4.0-1067-aws x86_64)

* Documentation:  https://help.ubuntu.com
* Management:     https://landscape.canonical.com
* Support:        https://ubuntu.com/advantage

Get cloud support with Ubuntu Advantage Cloud Guest:
   http://www.ubuntu.com/business/services/cloud

 34 packages can be updated.
 27 updates are security updates.

 New release '18.04.1 LTS' available.
 Run 'do-release-upgrade' to upgrade to it.


 Last login: Wed Oct 17 17:53:53 2018 from 173.48.231.135
ubuntu@ip-10-99-61-197:~$


Then the file /etc/ansible/hosts file (the uncommented section shown below) needs to be edited for the actual private IPs of the ceph nodes 
(since I am not using elastic (static) IPs)


[servers]
host1 ansible_ssh_host=10.99.61.225
host2 ansible_ssh_host=10.99.61.209
host3 ansible_ssh_host=10.99.61.217
host4 ansible_ssh_host=10.99.61.208
host5 ansible_ssh_host=10.99.61.146
host6 ansible_ssh_host=10.99.61.183

The cluster can be tested  for connectivity as follows:

ubuntu@ip-10-99-61-197:~$ ansible -m ping all
host2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
host3 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
host1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
host5 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
host4 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
host6 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
ubuntu@ip-10-99-61-197:~$


After that ceph can be installed into the cluster via the installer node.

The steps to install ceph are in the file ceph_install.txt (the install is via ansible)
It also contains the files that need change  and what those changes are. (mainly yml files)
