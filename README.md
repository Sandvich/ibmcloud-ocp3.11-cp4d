# Cloud Pak for Data installer for IBM Cloud

This repository houses a set of automation for deploying infrastructure, openshift 3.11, portworx, and cloud pak for data.

## Prerequisites

- Ansible
- terraform > 0.12
- [ibmcloud provider](https://github.com/IBM-Cloud/terraform-provider-ibm)

Note: you can install the provider by running the included `provider.sh` script. It will install v1.2.5, but this can be changed by editing the appropriate variable within the script.
  
## Files required

in a folder in the root of this repository called `installer_files` place 2 files for cloud pak install:

- cloudpak4data-ee-v2.5.0.0.tgz
- repo.yaml

These can be acquired by running the CP4D bin file. The repo.yaml should be completed with your details so that installation of the cloud pak is successful.

## Variables

There are a few variables that must be set for the install to take place successfully.

- [ibmcloud_api_key](https://cloud.ibm.com/docs/iam?topic=iam-userapikey)
- iaas_classic_username (this is your login for IBM cloud)
- [iaas_classic_api_key](https://cloud.ibm.com/docs/iam?topic=iam-classic_keys)
- redhat_un
- redhat_pw
- [openshift_pool_id](https://access.redhat.com/solutions/253273) (the rhsm pool with the appropriate licenses)
- domain (a domain that already exists in IBM Cloud)
  
Additionally it is recommended to set additional variables:

- ssh-key (a list of strings with the ID of an ssh key already in IBM Cloud)
- cluster_name (a random string, used for your cluster URL)
- region
- datacenter
- tags (a list of strings of tags to apply to the infrastructure)

## Deployment

**If you intend to use the portworx instance as your primary storage method you must deploy a minimum of 3 worker nodes**

To run this deployment run this series of commands from the root folder

```bash
# Optional commands
terraform init
terraform plan #check your plan is as expected

# the first thing the ansible playbook does is run the terraform to provision your infrastructure
ansible-playbook main.yaml
```

due to some complications with the deployment of ocp the last command must be run from the installer node provisioned during the deployment.
This command will also be printed at the end of the previous playbook as a one-liner
It is recommended to run this in a `tmux` session as it can take a long time to complete

```bash
ssh root@<installer_ip> -i <project_dir>/installer_files/id_rsa
ansible-playbook /opt/installer/main.yaml
```

## Post Install

Your cluster will be up and available at a url with this format
`https://console.apps.<cluster_name>.<domain>`

The default credentials are:
currently the password is unable to be changed until after the cloud pak is installed.

```text
username: ocpadmin
password: Ch4ngeM3
```
