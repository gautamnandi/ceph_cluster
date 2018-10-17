#!/bin/bash
set -x
# output log of userdata to /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
cat > /home/ubuntu/aws.pem <<'_END'
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAysLjsgLhaDyJruDzSRBNNORTtrLJxfpGG/P9zU6aV0QyfL5I
IFRNZoBtMDhWX4vWn88k2zr26JPnLUHBKmX36qVx0adNaNXLezQ7WDXnRzrzy13Q
WGX5MZOJ/zw00AdoDZFia8InOUOhgBGZMgUiroZUdW4Nh2qcnVMwzFzoyRE/hdD/
aMqLzPJ//IHc9YEO7Ckdtk/mCktaWlIRKUB215l1895xsVR6Ke2g84xvIDeMEGiZ
noqNvoxlY340Zcg4lDcADxNRgYKFRGC5UxH16GdWzBqQYnOl3/XXpdkjsIhd4Juj
zr8i/81sYE1aEGMkC+JZsVhUn5U9eGg4YPBgXwIDAQABAoIBAA80AcKtOJ2KPICi
WVuXH1Lh8+z1BvATTgJ2jwc/5463jFmSIvJZn9wZsRY2gzNy1srwy0Cs8SqLPIBG
N+en8ajkct5XfxRnQ3Sfe/unPwo2P2V2SVL3gnHXMDe1GfinNYQe7JRL4IkIqylh
KG15uRoA9IBBmj4XHlsli7knFkVNJZfnI4LCrNX35LD6HuWScb6aAW8dmyx/kR9l
TlFGvZUEBJIFbgeejX0Ff4ecKVj9xhmBfLCUIhZYBlf6YcGhVQKzBQrPIC9fCOj+
ypFSKBrl6EOYmATp+fauw3Z4Vz8Db6oyxZemhbCqln0GNuhhwBal6dzjc47OByKP
SCc0VNECgYEA7Dihw8HtsnpWf9TLjBuejXS6CLA6TaI+xPelyi/xyNWHOJo9BpGv
0dCpn9KNE+DXQYyiQS9Ka/r6SACnjn1Of7hKH18rEF6fx7c60Cprm4gNDAqBt9YO
VpiKZg3sZbGrCNPIR3kPlFAB6KFRsEfaJC9tiBaif4XSWjbYi3gf8RUCgYEA270M
dqE6BIdlk/VYV1O4PUU58To6/DePrUyqhVrGqg+9wuwf567F1lHRDUL67jPbSP1I
yKVjNb51onBzKJB7CxClGlB1Ygj7hgPxUQhQAfduPIH+xAxYCBTZQS8eJN3ngfnX
BK/pAGcN7dVzsjEcGB3+OLZ2Cym5aMy9e5nqYKMCgYA2A/UpmEzMRSFGddhdn2sw
GYL4vaN3YSRNUfu9Mh1tuTYEgXB28hVsOvSusSzFYOKYAJqRoUi5TFiy4kNuV8T9
e5ync9GbGqgauRFfzHNyyzeAi16CNRZuQs9S6tgloOzlRdhET7B6T5lAIrNVRfjh
0V6QgeyCkI07R9NYgQ18yQKBgQCE2E0hpyVROZ4SjmBjIy0edayrBv5EHz8QkWoC
BzhV9gBOSLydL89RW9NcBiN4QQeQn/gRvdM12bh6hStJ2ddZgC2gtAXTSATwJ5AL
4k+kcLdHg3vHgIL0F86kltzNgw6ESMxSfBsMcEE+iS5SC1ilx/Q6yyygYRBDqIvh
ntLQqwKBgGe8KPyWPnpHl5e7HZszw9IOOWLnbreyv0n6bb1Sf7hDe2hpNY7lLc5Q
I8OVAR9DTPmC5dS0jqfuR/Xkpj44lyQXVpeiYfM+HCFJyv4iWcRepPr8zPDkw+CM
uNmlkt/7Sv6SXnfBrw/TjBNjEDnD3/nmv1o6nKA/YkZEhuc2qtol
-----END RSA PRIVATE KEY-----
_END
chmod 400 /home/ubuntu/aws.pem
chown ubuntu:ubuntu /home/ubuntu/aws.pem

cat > /home/ubuntu/.ssh/config <<'_END'
Host 10.99.61.*
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
_END
chown ubuntu:ubuntu /home/ubuntu/.ssh/config

apt-add-repository -y ppa:ansible/ansible
apt-get -y update
apt-get -y install ansible

cat >> /etc/ansible/hosts <<'_END'
[servers]
host1 ansible_ssh_host=10.99.61.213
host2 ansible_ssh_host=10.99.61.228
host3 ansible_ssh_host=10.99.61.150
host4 ansible_ssh_host=10.99.61.222
host5 ansible_ssh_host=10.99.61.140
host6 ansible_ssh_host=10.99.61.182
_END

mkdir /etc/ansible/group_vars
cat > /etc/ansible/group_vars/servers <<'_END'
ansible_ssh_private_key_file: /home/ubuntu/aws.pem
_END
