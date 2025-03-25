# Install Vagrant and VirtualBox

Vagrant is a tool for building and distributing development environments. It works with virtualization software such as VirtualBox to provide a consistent and portable development environment.

VirtualBox is a free and open-source hosted hypervisor for x86 virtualization. It allows you to run multiple guest operating systems on a single host machine.

## Installation

```powershell
winget install virtualbox
winget install vagrant
```

**Restart the computer after installation**

### Create a new directory and navigate to it:

```powershell
mkdir lab-docker-vagrant
cd lab-docker-vagrant
```

### Initialize a new Vagrant environment:

```powershell
vagrant init
```

### Start VSCode:

```powershell
code .
```

### Open the `Vagrantfile` and add the following configuration:

<!-- Add the following configuration to the `Vagrantfile`: -->

```ruby
# You can use different images to create your virtual machines.
# Check the available images at https://portal.cloud.hashicorp.com/vagrant/discover
# Create 2 or more virtual machines with the following configuration:
machines = {
  "master" => {"memory" => "512", "cpu" => "1", "ip" => "100", "image" => "bento/ubuntu-24.04"},
  "node01" => {"memory" => "512", "cpu" => "1", "ip" => "101", "image" => "bento/ubuntu-24.04"},
  "node02" => {"memory" => "512", "cpu" => "1", "ip" => "102", "image" => "bento/ubuntu-24.04"},
  "node03" => {"memory" => "512", "cpu" => "1", "ip" => "103", "image" => "bento/ubuntu-24.04"},
  "node04" => {"memory" => "512", "cpu" => "1", "ip" => "104", "image" => "bento/ubuntu-24.04"}
}

Vagrant.configure("2") do |config|

  machines.each do |name, conf|
    config.vm.define "#{name}" do |machine|
      machine.vm.box = "#{conf["image"]}"
      machine.vm.hostname = "#{name}"
      machine.vm.network "public_network"
      machine.vm.provider "virtualbox" do |vb|
        vb.name = "#{name}"
        vb.memory = conf["memory"]
        vb.cpus = conf["cpu"]

      end
      machine.vm.provision "shell", path: "docker.sh"
    end
  end
end
```

### Create a new file named `docker.sh` and add the following script:

**_Example_**

```sh
#!/bin/bash

echo "Instalando o Docker......."

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh --dry-run
```

### Start the Vagrant application:

```powershell
vagrant up
```

#### When prompted, select the network interface:

```powershell
Which interface should the network bridge to? 1
```

Default SSH username: `vagrant`  
Default SSH password: `vagrant`

### Access the virtual machines:

#### Choose one of the virtual machines to access:

```powershell
vagrant ssh master
```

#### Superuser access

```bash
sudo su
```

#### Show the IP address of the virtual machine:

```bash
ip a
```

#### Choose eth1: example 192.168.0.100/24 interface to get the IP address.

**_Example_**

```bash
docker swarm init --advertise-addr 192.168.0.100
```

#### Copy the command that was generated.

**_Example_**

```bash
docker swarm join --token SWMTKN-1-4
```

#### Open another terminal and access the second virtual machine:

**_Example_**

```powershell
vagrant ssh node01
```

#### Superuser access

```bash
sudo su
```

#### Paste the command that was generated in the first virtual machine.

**_Example_**

```bash
docker swarm join --token SWMTKN-1-4
```

### Continue adding more virtual machines to the swarm if necessary.

#### Check all docker swarm nodes:

```bash
docker node ls
```

## Creating a service

**Check if there are any services running**

```bash
docker service ls
```

**Create a new service: Example Apache Server**
**_Example_**

```bash
docker service create --name webserver --replicas 3 -p 80:80 httpd
```

**Check the service status**

```bash
docker service ls
```

**Check which nodes the service is running on**

```bash
docker service ps webserver
```

**Check in the browser if the service is running**

Open your browser and access the IP address of one of the virtual machines:
You can check the IP address of the virtual machines using the command `ip a`.

**_Example_**
eth1: http://192.168.0.100

**Restrict node manager to only orchestrate services**

```bash
docker node update --availability drain master
```

**Removing services**

```bash
docker service rm webserver
```

**Creating a data volume to have consistency in clusters**

```bash
docker volume create app
```

**Check if the volume was created**

```bash
docker volume ls
```

**Check in which node the volume is located**

```bash
docker volume inspect app
```

### Practicing

**Create a index.html file into the volume**

```bash
nano /var/lib/docker/volumes/app/_data/index.html
```

**Replication of data in the volume**

```bash
docker service create --name my-app --replicas 7 -dt -p 80:80 --mount type=volume,src=app,dst=/usr/local/apache2/htdocs httpd

```

**Install nfs server in node manager to share the volume between the nodes**

```bash
apt install nfs-server -y
```

**Config NFS Server**

```bash
cd /var/lib/docker/volumes/app/_data/

nano /etc/exports
```

Paste the following configuration in final the document /etc/exports

```nano
/var/lib/docker/volumes/app/_data/ *(rw,sync,subtree_check)
```

Save (CTRL+o) and close (CTRL+x) the file

**Exports the shared directory**

```bash
exportfs -ar
```

**Open NFS Firewall**

**Install NFS client in the other nodes**

```bash
apt install nfs-common -y
```

### Show the shared directory

**_Example_**
private ipv4 number

```bash
showmount -e 172.31.0.185
```

**Open All UDP and TCP ports**

**Mount in the other nodes**
**_Example_**
private ipv4 number

```bash
mount 172.31.0.185:/var/lib/docker/volumes/app/_data
```

**_Reply on the other nodes if necessary_**

## Sharing Database in cluster

**_Example_**
Create a MySQL database

```bash
docker volume create data

docker run -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=mysql --name MYSQL8.4-ALPHA -d -p 3306:3306 --mount type=volume,src=data,dst=/var/lib/mysql mysql:8.4
```

**Check container status**

```bash
docker ps
```

**Open a SGBD client and connect to the database**

```bash
docker exec -it MYSQL8.4-ALPHA mysql -u root -p
```

Insert the password: password

### Create a database

```sql
SHOW DATABASES;
CREATE DATABASE IF NOT EXISTS webapp;
USE webapp;
SHOW TABLES;
CREATE TABLE IF NOT EXISTS dataset (
    id int,
    data1 varchar(50),
    data2 varchar(50),
    hostname varchar(50),
    ip varchar(50)
);
SHOW TABLES;
DESC TABLE dataset;
```

## Create services to access the database

```bash
docker service create --name webapp --replicas 5 -dt -p 80:80 --mount type=volume,src=app,dst=/app/ webdevops/php-apache:alpine-php7
```

**Check the service status**

```bash
docker service ls

docker service ps webapp
```

## Stressing Application after load balancing

Navigate to the browser and access any website that generates a lot of traffic, such as [https://loader.io/](https://loader.io/)
Register your account and follow the instructions
Paste in directory where you have your index.html file the following code:

```bash
nano /var/lib/docker/volumes/app/_data/loaderio-{HASH_NUMBER}.txt
```

Write anything as: loaderio-90a46d8d5804decb39b6d3d73960aec4
Save and close the file
Continue followig the instruction from website to strees the loadbalancer
