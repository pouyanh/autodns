# Janstun Docker Automatic DNS and Load Balance Solution
Lets you to access your running docker containers using a domain name instead of container's ip address. Automatically balances load between scaled containers using haproxy

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
docker exec autodns_dns_1 cat /etc/dnsmasq.d/default
```

## Retrieve haproxy live configuration
```bash
docker exec autodns_haproxy_1 cat /usr/local/etc/haproxy/haproxy.cfg
```

Visit http://haproxy.local:8181/haproxy?stats to see haproxy statistics
