# Janstun Docker Automatic DNS and Load Balance Solution
Lets you to access your running docker containers using a domain name instead of container's ip address

## Setup
1. Set primary dns server to docker (172.17.0.1) using system preferences or writing to one of files described below:
  * /etc/resolvconf.conf: name_servers=172.17.0.1
  * /etc/resolv.conf: nameserver 172.17.0.1
2. Run containers: ```docker-compose up -d```

## Usage
Set *HOSTNAME* environment variable on your container:
```bash
docker run -e HOSTNAME=cms.jst wordpress:latest
```
Your container is accessible by value of *HOSTNAME*

## Retrieve list of DNS records
```bash
docker exec dns_dnsmasq-conf_1 cat /etc/dnsmasq.d/default
```
