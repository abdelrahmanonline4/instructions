# Install Ansible AWX

This guide provides scripts and configurations to install and set up Ansible AWX, an open-source web-based interface, REST API, and task engine for Ansible.

![AWX Installation](https://github.com/user-attachments/assets/52c7a5af-438c-4f41-9f05-d45f1e1fcaaa)

## Prerequisites

Before starting the installation, ensure you have an Ubuntu server (recommended specifications: 4 CPUs and 8 GB RAM) up and running. You will need root or sudo privileges to execute the necessary commands.

---

## Step 1: Update and Upgrade System Packages

Run the following commands to update and upgrade your system packages:

```bash
sudo apt update -y
sudo apt upgrade -y
```

## Step 2: Install Ansible and Required Packages

Use the commands below to install Ansible and the required packages:

```bash
sudo apt install python-setuptools -y
sudo apt install python3-pip -y
sudo pip3 install ansible
ansible --version
pip3 install docker==6.1.3
sudo pip3 install docker-compose
docker-compose version
```

## Step 3: Grant Docker Access to the Current User

Run this command to grant Docker access:

```bash
sudo usermod -aG docker $USER
```

## Step 4: Install Required Packages for AWX Setup

Install additional packages required for the AWX setup:

```bash
sudo apt install git vim pwgen -y
```

## Step 5: Clone the Ansible AWX Repository

Clone the AWX repository using the following command:

```bash
sudo git clone https://github.com/ansible/awx.git --branch 17.0.1 --depth 1
```

## Step 6: Generate a Secret Key and Modify the Inventory File

Navigate to the `installer` directory and generate a secret key:

```bash
cd awx/installer
pwgen -N 1 -s 30  # to get secretkey
```

Edit the `inventory` file:

```bash
sudo vi inventory
```

Replace the `admin_password` and `secret_key` with your desired values. Here’s a sample inventory file:

```ini
localhost ansible_connection=local ansible_python_interpreter="/usr/bin/python3"

[all:vars]

dockerhub_base=ansible
awx_task_hostname=awx
awx_web_hostname=awxweb
postgres_data_dir="~/.awx/pgdocker"
host_port=80
host_port_ssl=443
docker_compose_dir="~/.awx/awxcompose"

pg_username=awx
pg_password=awxpass
pg_database=awx
pg_port=5432

admin_user=admin
admin_password=adminpass

secret_key=yourgeneratedsecretkey

create_preload_data=True
```

Save the file by pressing `Esc`, then type `:wq`.

## Step 7: Run the Ansible Playbook to Install AWX

Execute the playbook to start the installation:

```bash
ansible-playbook -i inventory install.yml
```

## Step 8: Access the AWX Web Interface

After the installation, access the AWX web interface by navigating to `http://your-server-ip` in your web browser. Use the username `admin` and the `admin_password` you specified in the inventory file.

Once you log in, you should see a dashboard similar to the image below:

![AWX Dashboard](https://github.com/user-attachments/assets/f672ddca-a874-4fd9-93cb-3e6e06a88adf)
