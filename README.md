# Janstun Docker Automatic DNS and Load Balance Solution
Lets you to access your running docker containers using a domain name instead of container's ip address. Automatically balances load between scaled containers using haproxy

## Setup
1. Customize environment by creating a `docker-compose.override.yml` file (Sample override file is available as [`docker-compose.override.yml.sample`](docker-compose.override.yml.sample)):
    * Check your docker daemon's ip address (default: 172.17.0.1):
        ```bash
        ip addr show docker0 | grep inet
        ```
    * If docker daemon's ip address differs from default, you have to set it in *dnsmasq-conf* docker container's *HOST_IP* environment variable
    * DNS service automatically binds to port 53 on all interfaces. If this port on your host is already in-use (maybe because of having another running dns server) you can change autodns bridge network's default bind ip address from 0.0.0.0 (all interfaces) to your docker0 interface ip address by setting **com.docker.network.bridge.host_binding_ipv4** in *networks.default.driver_opts*
2. Run containers: ```docker-compose up -d```
3. Set autodns' dns server, reachable from docker0 interface ip address (default: 172.17.0.1), as host's primary dns server using one of these methods:
    * Network manager
    * System preferences
    * Configuring resolve manager (resolveconf) by writing to `/etc/resolvconf.conf`:
        ```
        name_servers=AUTODNS_DNS_SERVER_IP_ADDRESS
        ```
        And running `sudo resolvconf -u`
    * Directly adding to `/etc/resolv.conf`:
         ```
         nameserver AUTODNS_DNS_SERVER_IP_ADDRESS
         ```

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
.
## Retrieve haproxy live configuration
```bash
docker exec autodns_haproxy_1 cat /usr/local/etc/haproxy/haproxy.cfg
```

Visit http://haproxy.local/haproxy?stats to see haproxy statistics
