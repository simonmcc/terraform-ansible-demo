# terraform-ansible-demo

Minimal demo using [terraform.py](https://github.com/CiscoCloud/terraform.py) and an AWS VPC & CentOS 7 instance.  terraform.py has been tweaked slightly to speed up finding the terraform.state file.

## Usage

	$ terraform plan
	Refreshing Terraform state in-memory prior to plan...
	The refreshed state will be used to calculate this plan, but
	will not be persisted to local or remote state storage.
	
	aws_vpc.default: Refreshing state... (ID: vpc-9d6d3cf9)
	aws_key_pair.user_key: Refreshing state... (ID: user_key)
	data.aws_ami.centos7: Refreshing state...
	aws_subnet.eu-west-1a-public: Refreshing state... (ID: subnet-1cd6f16a)
	aws_internet_gateway.default: Refreshing state... (ID: igw-4934fe2d)
	aws_security_group.web: Refreshing state... (ID: sg-b0771dd6)
	aws_route_table.eu-west-1a-public: Refreshing state... (ID: rtb-e0907387)
	aws_route_table_association.eu-west-1a-public: Refreshing state... (ID: rtbassoc-813b68e6)
	aws_instance.centos7: Refreshing state... (ID: i-0ed32f887225b98a5)
	
	No changes. Infrastructure is up-to-date. This means that Terraform
	could not detect any differences between your configuration and
	the real physical resources that exist. As a result, Terraform
	doesn't need to do anything.

Terraform has built a single accessible server, which we can now maintain via [Ansible](https://www.ansible.com/)	
	
	$ ansible -i ./terraform.py -m ping all
	CentOS Server | success >> {
	    "changed": false,
	    "ping": "pong"
	}
	
	$


## tweaks
* sys.settrace from [https://pymotw.com/2/sys/tracing.html](https://pymotw.com/2/sys/tracing.html)


## terraform.py performance tweak

Vanilla terraform.py:

    simonm@MacBook:terraform-ansible-demo (master) AWS=jdr $ time ./terraform.py --list
    {"aws_ami=ami-0307d674": {"hosts": ["Ubuntu Server"]}, "_meta": {"hostvars": {"CentOS Server": {"ami": "ami-7abd0209", "ephemeral_block_device": [], "availability_zone": "eu-west-1a", "public_ipv4": "52.214.11.78",
    "key_name": "user_key", "private": {"ip": "10.0.0.46", "dns": "ip-10-0-0-46.eu-west-1.compute.internal"}, "tenancy": "default", "root_block_device": [{"volume_size": "8", "iops": "0", "delete_on_termination": "false",
    "volume_type": "standard"}], "ansible_ssh_port": 22, "id": "i-0e5a1ae1915f9a1ae", "tags": {"sshUser": "centos", "%": "2", "Name": "CentOS Server"}, "ansible_ssh_user": "centos", "subnet": {"id": "subnet-941f38e2"},
    "consul_dc": "root", "ebs_optimized": false, "ansible_python_interpreter": "python", "ansible_ssh_host": "52.214.11.78", "ebs_block_device": [], "role": "none", "security_groups": [], "provider": "aws", "private_ipv4":
    "10.0.0.46", "consul_is_server": false, "public": {"ip": "52.214.11.78", "dns": "ec2-52-214-11-78.eu-west-1.compute.amazonaws.com"}, "vpc_security_group_ids": ["sg-8df59eeb"]}, "Ubuntu Server": {"ami": "ami-0307d674",
    "ephemeral_block_device": [], "availability_zone": "eu-west-1a", "public_ipv4": "52.18.251.88", "key_name": "user_key", "private": {"ip": "10.0.0.161", "dns": "ip-10-0-0-161.eu-west-1.compute.internal"}, "tenancy":
    "default", "root_block_device": [{"volume_size": "8", "iops": "100", "delete_on_termination": "true", "volume_type": "gp2"}], "ansible_ssh_port": 22, "id": "i-0ec62249d9afaf8e9", "tags": {"sshUser": "ubuntu", "%": "2",
    "Name": "Ubuntu Server"}, "ansible_ssh_user": "ubuntu", "subnet": {"id": "subnet-941f38e2"}, "consul_dc": "root", "ebs_optimized": false, "ansible_python_interpreter": "python", "ansible_ssh_host": "52.18.251.88",
    "ebs_block_device": [], "role": "none", "security_groups": [], "provider": "aws", "private_ipv4": "10.0.0.161", "consul_is_server": false, "public": {"ip": "52.18.251.88", "dns":
    "ec2-52-18-251-88.eu-west-1.compute.amazonaws.com"}, "vpc_security_group_ids": ["sg-8df59eeb"]}}}, "aws_tag_Name=Ubuntu Server": {"hosts": ["Ubuntu Server"]}, "aws_key_name=user_key": {"hosts": ["Ubuntu Server", "CentOS
    Server"]}, "aws_tag_sshUser=centos": {"hosts": ["CentOS Server"]}, "aws_az=eu-west-1a": {"hosts": ["Ubuntu Server", "CentOS Server"]}, "dc=root": {"hosts": ["Ubuntu Server", "CentOS Server"]}, "aws_tenancy=default":
    {"hosts": ["Ubuntu Server", "CentOS Server"]}, "aws_vpc_security_group=sg-8df59eeb": {"hosts": ["Ubuntu Server", "CentOS Server"]}, "aws_subnet_id=subnet-941f38e2": {"hosts": ["Ubuntu Server", "CentOS Server"]},
    "aws_tag_Name=CentOS Server": {"hosts": ["CentOS Server"]}, "aws_tag_%=2": {"hosts": ["Ubuntu Server", "CentOS Server"]}, "aws_tag_sshUser=ubuntu": {"hosts": ["Ubuntu Server"]}, "aws_ami=ami-7abd0209": {"hosts": ["CentOS
    Server"]}, "role=none": {"hosts": ["Ubuntu Server", "CentOS Server"]}}

    real  1m43.242s
    user  0m16.831s
    sys 0m55.697s
    simonm@MacBook:terraform-ansible-demo (master) AWS=jdr $


After removing the os.walk(../../) with a os.walk(os.getcwd()):

    $ time ./terraform.py --list
    {"aws_subnet_id=subnet-1cd6f16a": {"hosts": ["CentOS Server"]}, "_meta": {"hostvars": {"CentOS Server": {"ami": "ami-7abd0209", "ephemeral_block_device": [], "availability_zone": "eu-west-1a",
    "public_ipv4": "52.213.118.120", "key_name": "user_key", "private": {"ip": "10.0.0.34", "dns": "ip-10-0-0-34.eu-west-1.compute.internal"}, "tenancy": "default", "root_block_device":
    [{"volume_size": "8", "iops": "0", "delete_on_termination": "false", "volume_type": "standard"}], "ansible_ssh_port": 22, "id": "i-0ed32f887225b98a5", "tags": {"sshUser": "centos", "%": "2",
    "Name": "CentOS Server"}, "ansible_ssh_user": "centos", "subnet": {"id": "subnet-1cd6f16a"}, "consul_dc": "root", "ebs_optimized": false, "ansible_python_interpreter": "python",
    "ansible_ssh_host": "52.213.118.120", "ebs_block_device": [], "role": "none", "security_groups": [], "provider": "aws", "private_ipv4": "10.0.0.34", "consul_is_server": false, "public": {"ip":
    "52.213.118.120", "dns": "ec2-52-213-118-120.eu-west-1.compute.amazonaws.com"}, "vpc_security_group_ids": ["sg-b0771dd6"]}}}, "aws_az=eu-west-1a": {"hosts": ["CentOS Server"]},
    "aws_key_name=user_key": {"hosts": ["CentOS Server"]}, "aws_ami=ami-7abd0209": {"hosts": ["CentOS Server"]}, "aws_tenancy=default": {"hosts": ["CentOS Server"]},
    "aws_vpc_security_group=sg-b0771dd6": {"hosts": ["CentOS Server"]}, "aws_tag_sshUser=centos": {"hosts": ["CentOS Server"]}, "aws_tag_Name=CentOS Server": {"hosts": ["CentOS Server"]},
    "aws_tag_%=2": {"hosts": ["CentOS Server"]}, "role=none": {"hosts": ["CentOS Server"]}, "dc=root": {"hosts": ["CentOS Server"]}}

    real  0m0.132s
    user  0m0.039s
    sys 0m0.035s


