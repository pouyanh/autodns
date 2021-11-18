# Automatic DNS and Load Balancer for Docker Containers
Enables access to docker containers over virtual internal network using a domain name, e.g., *myapp.tst*
just by setting an environment variable, i.e., `HOSTNAME` on that container, instead of ip address.
It automatically adds dns record on container start and removes the dns record on container stop and balances load
between scaled containers using haproxy. No docker network sharing or containers linkage required.

## Setup
0. Reveal docker daemon's ip address:
   
   Command below reveals docker daemon's ip address:
   ```bash
   ip addr show docker0 | grep inet | awk '{ print $2 }' | awk -F'/' '{ print $1 }'
   ```
   
1. Change default configurations if necessary (*Optional*):
   
   Create a `docker-compose.override.yml` file to override default configurations.
   You can copy the sample [docker-compose.override.yml.sample](docker-compose.override.yml.sample) file and modify it
   according to your situation. Here are some scenarios which require an override file:
   
   * Docker daemon's ip address differs from default, i.e., *172.17.0.1*:

     Set `HOST_IP` environment variable for *dnsmasq-conf* service.

   * Port 53 is already in-use by another dns service such as bind or dnsmasq
     (Ubuntu's default network manager has a builtin dnsmasq):

     *dnsmasq* service automatically binds to port 53 on all interfaces, *INADDR_ANY*, i.e., *0.0.0.0* & *::*.
     Bridge network's binding ip address can be set to ip address of docker0 interface
     by setting `com.docker.network.bridge.host_binding_ipv4` under `networks.default.driver_opts` element.
     
2. Start & Enable autodns:
   
   All autodns services automatically start whenever docker service starts, e.g., os startup or docker service restart.
   To start & enable it run:
   ```bash
   docker-compose up -d
   ```
   
3. Add autodns to list of active dns servers:

   Either *dnsmasq* service binds to port 53 of all interfaces, *INADDR_ANY*, or just the docker0 interface
   it's almost reachable from docker0 interface ip address (step 0).
   Considering customizations in step 1, if bridge network's binding ip address is something different from
   *INADDR_ANY* or docker0 interface ip address you have to know it.
   Anyway let's name it **AUTODNS_DNS_SERVER_IP_ADDRESS**.

   On linux there are several ways to specify dns servers manually. It's important to make sure that autodns
   having the highest priority in list of dns servers, i.e., it should be the primary dns server.
   
   Don't worry about corruption in the global dns resolve procedure because it automatically switches to
   next dns server if current one fails in resolving the request. *dnsmasq* service only knows ip addresses of
   running docker containers which want to be resolvable by autodns, i.e., have the `HOSTNAME` environment variable.
   So it says IDK for any other hosts not being listed by itself and lets next dns server get involved.
   
   Here are some alternative ways to add a dns server manually:
   
    * DNS resolver configurator, i.e., *resolvconf* (recommended):
      
      Add **AUTODNS_DNS_SERVER_IP_ADDRESS** to `/etc/resolvconf.conf`:
      ```
      name_servers="AUTODNS_DNS_SERVER_IP_ADDRESS [other dns servers]"
      ```
      Then run:
      ```bash
      sudo resolvconf -u
      ```
      
   * Operating System's network manager:

     Set **AUTODNS_DNS_SERVER_IP_ADDRESS** as the primary dns server of the active interface
     
   * System preferences
   * Directly writing to DNS resolver configuration file (not recommended):
     
     Add **AUTODNS_DNS_SERVER_IP_ADDRESS** to top of `/etc/resolv.conf`:
     ```
     nameserver AUTODNS_DNS_SERVER_IP_ADDRESS
     ```
     **Caution**: Content of `/etc/resolv.conf` may become overridden by other tools such as *resolvconf*

## Usage
Set `HOSTNAME` environment variable on your container:
```bash
docker run -e HOSTNAME=cms.jst wordpress:latest
```
Your container is reachable by value of `HOSTNAME`, i.e., *cms.jst* in this example. Test it by:
```bash
dig cms.jst
```

## View status
* View list of dns records listed in *dnsmasq*:

  ```bash
  docker exec autodns-dns-1 cat /etc/dnsmasq.d/default
  ```

* View haproxy live configuration:

  ```bash
  docker exec autodns-haproxy-1 cat /usr/local/etc/haproxy/haproxy.cfg
  ```

* View haproxy live statistics:

  Visit [http://haproxy.local/haproxy?stats](http://haproxy.local/haproxy?stats) in a browser to see haproxy statistics
