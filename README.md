# Shoebox

### What is it?

Shoebox is an all-in-one bundle of tutorials and scripts (shell & docker-compose) for setting up a simple collaborative software development environment. It can be hosted on a VPS or dedicated server as an inexpensive alternative for subscription based could services. Software components used in this setup are either open source or have free versions (some with limitations, please check).

| Tool                                | Vendor                                                            | License                                                                                                                                                                                      |
| :---------------------------------- | :---------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Git Server                          | [Gogs](https://gogs.io/)                                          | [MIT](https://github.com/gogs/gogs/blob/master/LICENSE)                                                                                                                                      |
| Secret Management                   | [Vault](https://www.vaultproject.io/)                             | [MPL-2.0](https://github.com/hashicorp/vault/blob/master/LICENSE)                                                                                                                            |
| Package Management                  | [Ideo Proget](https://inedo.com/proget)                           | [ProGet License Agreement](https://inedo.com/proget/license-agreement) <br /> [Free Edition Limitations](https://docs.inedo.com/docs/proget/administration/license#free-edition-limitations) |
| Docker Registry                     | [Docker Registry](https://docs.docker.com/registry/)              | [Apache-2.0](https://github.com/docker/distribution/blob/master/LICENSE)                                                                                                                     |
| Docker Registry UI                  | [Joxit Docker Registry UI](https://joxit.dev/docker-registry-ui/) | [AGPL-3.0](https://github.com/Joxit/docker-registry-ui/blob/master/LICENSE)                                                                                                                  |
| Continuous Integration and Delivery | [Drone CI](https://drone.io/)                                     | [Drone Non-Commercial License](https://github.com/drone/drone/blob/master/LICENSE) <br /> [Waiver: Individual and Small Business](https://github.com/drone/drone/blob/master/LICENSE#L62)    |
| Project Management                  | [Taiga](https://taiga.io/)                                        | [Taiga Backend - AGPL-3.0](https://github.com/taigaio/taiga-back/blob/master/LICENSE) <br /> [Taiga Front - AGPL-3.0](https://github.com/taigaio/taiga-front/blob/master/LICENSE)            |

goto: [TL;DR](#tldr)

### Why does this exist?

The short answer is because of [“Those goddamn AWS charges!”](https://www.youtube.com/watch?v=982wFqC03v8).

On a serious note, we believe that even small teams can benefit from using a fully equipped development environment without paying a premium for infrastructural services from cloud service providers.

> INFO: The latter is less actual for open source projects. Usually, most of the tools mentioned in this setup are provided free of charge by major vendors.

And lastly, this setup is a result of our ([mich4xD](https://github.com/mich4xD) and [bahram-aliyev](https://github.com/bahram-aliyev])) "valor" attempt to document and automate the deployment of essential services for a development environment when working on a personal project.

### How does it work?

This setup requires a Linux machine with root access and system requirements matching the following:

- Minimum:

  - OS: Linux CentOS/RHEL 7.0
  - CPU: 2 vCPU
  - RAM: 4 GB
  - Storage: 20 GB
  - Network: 1 static IPv4 address

- Recommended:

  - OS: Linux CentOS/RHEL 7.0
  - CPU: 4 vCPU
  - RAM: 6 GB
  - Storage: 30 GB
  - Network: 1 IPv4 address

> INFO: This setup was tested and staged on CentOS 7.0, that is why this OS mention as a requirement. However, with minor adjustments (if any) it should work on any other popular Linux distributive.

Considering the physical host, there are three options to choose from.

> IMPORTANT: None of the vendors listed below have a sponsorship or advertisement agreement with the authors. Likewise, the authors are not responsible or liable for any damage or inconvenience caused by actions or inactions of the vendors.

1. Rent a Linux VPS.

   There are a few affordable options in a price range of 7 to 15 USD per month. The vendors listed below offer solutions matching or comparable to the desired system requirements and price range.

   - [VPSDime](https://vpsdime.com/)
   - [OVHCloud](https://www.ovh.com/)
   - [Hostinger](https://www.hostinger.com/)
   - [Interserver](https://www.interserver.net/)
   - [Hostnoc](https://hostnoc.com/)
   - [VPSCheap](https://www.vpscheap.net/)
   - [VirMach ](https://virmach.com/)
   - [TheStack](https://portal.thestack.net/)

2. Rent a dedicated server.

   This option is usually more costly than renting a VPS, however, it provides extra computation power and storage capacity for the premium. There is a limited number of affordable options in a price range of 20 to 30 USD per month. Usually, the price range starts at a 50 USD per month threshold. The dedicated server option can be considered as an expansion path for future growth.
   
   > WARNING: When choosing a dedicated server it is recommended to avoid renting significantly outdated hardware. Old hardware can potentially yield less performance than a VPS with lesser cost.

   - [Nocix](https://www.nocix.net/)
   - [Wholesale Internet](https://www.wholesaleinternet.net/)
   - [Server Room](https://www.serverroom.net/)
   - [Primcast](https://www.primcast.com/)

3. Run a server on-premises.

   No comment on that, you are in full charge.

Either way, be mindful of the law of diminishing returns. For example, the premium paid for the extra storage on a VPS may equalize the VPS rental cost with the dedicated server monthly fee. The same is true for the dedicated server option, as the cost may eventually grow to the point where it is more reasonable to purchase services from a cloud service provider. Long story short, do back-of-the-napkin-math.

### Q/A

- How to help or contribute?

  We are no Linux gurus, Docker experts, or technical writing virtuosos, so you are more than welcome to contribute! File an issue ticket or even better open a pull requests, we will do our best to respond as soon as possible. Constructive criticism is highly appreciated.

- Any gotchas?

  Firstly, it is a single machine configuration incapable of running on a cluster. That potentially may become a problem when simultaneously running several build pipelines would degrade the performance of the other services. This deficiency should be resolved once the services are made deployable to a Kubernetes cluster.

  Secondly, the technology of your choice must support Docker containerization for using the Drone build pipeline. If if does not, consider consider using alternatives such as [Jenkins CI](https://jenkins.io/) or [Concourse](https://concourse-ci.org/). No setup script or documentation is provided for the alternative CI services currently, however it might be added in the future and you are more than welcome to contribute.

  And lastly, the current build pipeline is .NET Core biased. Please feel free to contribute and add pipeline configurations for other technologies.

- Future plans?

  As it is mentioned earlier, adding Kubernetes support is a high priory task on the list, however, we need to acquaint ourselves with the technology first.

  We will do our best to maintain the documentation and keep the scripts up-to-date, and continue adding new CI configurations for different technologies as the need arises (you are more than welcome to contribute).

- Shoebox - why the name?

  ...cus' it has something in it to getcha runnin'! :boom: :running: :checkered_flag:

  Shoebox is a symbolic name representing simple multipurpose storage for old toys, lego bricks, commix books, SEGA/Nintendo cartridges, Play Station disks, board game accessories... in short, for things that used to (or still) bring us joy. We believe that this "shoebox" contains a few "toys" that might help you brining a structure in teamwork and make collaborative software development with your peers more enjoyable. :nerd_face: :headphones: :computer:

### TL;DR

- Components: Git; CI/CD; Docker Registry; Package Management; Secrets Management; Project Management
- Minimum requirements: CentOS/RHEL 7.0; 2 vCPUs; 4 GB RAM; 20 GB storage; 1 IPv4 address
- Cons: Single machine configuration; Docker support is a MUST for the build pipeline
- Future plans: Add more build configurations; Move to K8s

## Setup Outline

- [Prerequisites](#prerequisites)
  - [Tools](#tools)
    - [Nano](#nano)
    - [Git client](#git-client)
  - [Infrastructure](#infrastructure)
    - [Disable SELinux](#disable-selinux)
    - [Apache and mod_ssl](#install-apache-with-mod_ssl)
    - [Docker and Docker Compose](#install-docker-and-docker-compose)
    - [Environment variables](#environment-variables)
      - [REPO_ROOT](#REPO_ROOT)
      - [YOUR_DOMAIN](#YOUR_DOMAIN)
      - [SHOEBOX_ROOT](#SHOEBOX_ROOT)
    - [SMTP relay](#smtp-relay)
- [Network](#network)
  - [DNS Provider](#dns-Provider)
    - [Account setup](#cloudflare-account-setup)
    - [Name servers](#cloudflare-name-servers)
    - [Disable HTTP proxy](#turn-off-http-proxy)
    - [DNS API Client](#cloudflare-dns-api-client)
  - [Subdomain Records](#subdomain-records)
  - [SSL Setup](#ssl-setup)
- [Services](#services)
  - [SSL Proxy Setup](#ssl-proxy-setup)
  - [Containers Infrastructure](#containers-Infrastructure)
  - [Service Setup](#services-setup)
  - [Backup Configuration](#backup-configuration)

## Prerequisites

### Tools

- #### Nano(Simple console-based text editor)

  ```
  $ sudo yum install nano
  ```

  Shortcuts:

  - Save changes: `ctrl` + `x`, `y`
  - Discard changes: `ctrl` + `x`, `n`
  - Cancel: `ctrl` + `x`, `ctrl` + `c`

- #### Git client

  ```
  $ sudo yum install git
  $ sudo git --version # to confirm `git` is successfully installed
  ```

### Infrastructure

- #### Disable SELinux

  > IMPORTANT: It is highly recommended to disable SELinux for avoiding issues with infrastructure services and Docker containers.

  Check SELinux status.

  ```
  $ sestatus

  Output
  SELinux status:                 enabled
  ...
  ...
  Current mode:                   enforcing
  ```

  If SELinux is `enabled` follow the instruction to disable it, otherwise, continue to the next section.

  Edit the SELinux configuration file

  ```
  $ sudo nano /etc/selinux/config
  ```

  Set the `SELINUX` setting to `disabled` and save the file

  ```
  SELINUX=disabled
  ```

  Reboot

  ```
  $ sudo shutdown -r now
  ```

  Check SELinux status, it is expect to be `disabled`.

  ```
  $ sestatus

  Output
  SELinux status:                 disabled
  ```

- #### Docker and Docker Compose

  - Install Docker

    ```
    $ sudo yum remove docker \
                    docker-client \
                    docker-client-latest \
                    docker-common \
                    docker-latest \
                    docker-latest-logrotate \
                    docker-logrotate \
                    docker-engine

    $ sudo yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2

    $ sudo yum-config-manager \
        --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo

    $ sudo yum install docker-ce docker-ce-cli containerd.io

    $ sudo systemctl enable docker
    $ sudo systemctl start docker

    $ sudo docker run hello-world # confirm Docker CE is successfully installed
    ```
  - Install Docker Compose

    > INFO: Check the latest stable Docker Compose version at https://github.com/docker/compose/releases

    ```
    $ export DOCKER_COMPOSE_VERSION=1.25.5 

    $ sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    $ sudo curl -L https://raw.githubusercontent.com/docker/compose/$DOCKER_COMPOSE_VERSION/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

    $ sudo chmod +x /usr/local/bin/docker-compose

    $ sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    $ sudo docker-compose --version # confirm Docker Compose is successfully installed
    ```

### Optional: SMTP relay

Certain services in this setup require an SMTP relay for sending email notifications. If your DNS provider includes a free email address, you may want to use the provider's SMTP server; otherwise, there are a few free emailing services with a limited number of message sent per day/month (at least 100 emails a day).

- [SendPulse](https://sendpulse.com/prices/smtp) (12,000/month)
- [Mailgun](https://www.mailgun.com/pricing-options) (10,000/month)
- [Mailjet](https://www.mailjet.com/pricing/) (6,000/month, 200/day)
- [SendGrid](https://sendgrid.com/marketing/sendgrid-services-cro/#pricing-app) (100/day)

### Environment Variables

> INFO: Review and modify if necessary.

- #### REPO_ROOT

  The destination path for cloning this repository.

  ```
  $ export REPO_ROOT=/tmp/shoebox
  $ echo $REPO_ROOT
  ```

- #### YOUR_DOMAIN

  The domain name for the server with hosted services.

  > IMPORTANT: Do not forget to replace `yourdomain.com` with the actual domain name.

  ```
  $ export YOUR_DOMAIN=yourdomain.com
  $ echo $YOUR_DOMAIN
  ```

- #### SHOEBOX_ROOT

  The root directory where the data and configuration files of the services are stored.

  ```
  $ export SHOEBOX_ROOT=/var/shoebox
  $ echo $SHOEBOX_ROOT
  ```

## Network

### DNS Provider

The DNS providers a DNS API that is used by Certbot for proofing the domain name ownership for the SSL certificate acquisition.
[Cloudflare](https://www.cloudflare.com/) is used as the default DNS provider for this setup.

> IMPORTANT: If Cloudflare is not an option, there is a few more [DNS providers compatible with Certbot](https://community.letsencrypt.org/t/dns-providers-who-easily-integrate-with-lets-encrypt-dns-validation/86438). In this case the actions described below must be adjusted accordingly.

> WARNING: If the selected DNS provider is not compatible with Certbot, the **Network** section is deemed incompatible. The certificate acquisition process and renewal setup must be conducted independently.

1. <a name="cloudflare-account-setup"></a> Create a [Cloudflare account](https://dash.cloudflare.com/sign-up), the basic plan is free of charge. Add your domain name as a website and complete the verification process for proving the domain name ownership.

2. <a name="cloudflare-name-servers"></a> Change the name servers in the control panel of your domain name provider to the Cloudflare's name servers. To get the name servers, navigate to `DNS -> Cloudflare nameservers`. Depending on the TTL set in the DNS control panel it may take some time for the change to take effect, keep `ping`-ing the domain name periodically.

3. <a name="turn-off-http-proxy"></a> Turn off the HTTP proxy for main and subdomain names. click the cloud icon ![Alt text](/resources/img/http_proxy_on.png?raw=true "HTTP proxy - ON") next to each domain/subdomain name to gray it out ![Alt text](/resources/img/http_proxy_off.png?raw=true "HTTP proxy - OFF").

   > WARNING: If the http proxy is not disabled, it will cause an obscure error response such as _ERR_TOO_MANY_REDIRECTS_.

4. <a name="cloudflare-dns-api-client"></a> Cloudflare DNS API client is used by Certbot for proofing the domain name ownership when acquiring an HTTPS certificate from [Let’s Encrypt](https://letsencrypt.org/).

   > INFO: Adjust the actions accordingly if the DNS provider is not Cloudflare.

   Create an ini file for the Cloudflare DNS API client,

   ```
   $ sudo mkdir -p /etc/letsencrypt
   $ sudo nano /etc/letsencrypt/letsencrypt.ini
   ```

   Copy-paste the following fragment.

   ```
   # Credentials and email for lets encrypt in Traefik
   DNS_CLOUDFLARE_EMAIL=@CLOUDFLARE_EMAIL
   DNS_CLOUDFLARE_API_KEY=@CLOUDFLARE_API_KEY
   LETSENCRYPT_EMAIL=@LETSENCRYPT_EMAIL
   ```

   Get the DNS API key: In the Cloudflare panel browse to `Overview -> Get your API token -> API Tokens -> Global API Key [View]`.

   Replace the following place holders in the next section with your values:

   - [cloudflare_email] - the Cloudflare login
   - [cloudflare_api_key] - the Global API key
   - [letsencrypt_email] - email for letsencrypt

   Export the following envirnoment variables:

   - export CLOUDFLARE_EMAIL=[cloudflare_email]
   - export CLOUDFLARE_API_KEY=[cloudflare_api_key]
   - export LETSENCRYPT_EMAIL=[letsencrypt_email]

     <br/><br/>

  Exeucute the following to update the ini file with your credentials for cloudflare and your lets encrypt email:

   ```
   $ sudo sed -i 's|@DNS_CLOUDFLARE_EMAIL$|'$CLOUDFLARE_EMAIL'|g' /etc/letsencrypt/letsencrypt.ini
   $ sudo sed -i 's|@DNS_CLOUDFLARE_API_KEY$|'$CLOUDFLARE_API_KEY'|g' /etc/letsencrypt/letsencrypt.ini
   $ sudo sed -i 's|@LETSENCRYPT_EMAIL$|'$LETSENCRYPT_EMAIL'|g' /etc/letsencrypt/letsencrypt.ini
   ```

   Run `$ sudo cat /etc/letsencrypt/letsencrypt.ini` to verify the result.

### Subdomain Records

> IMPORTANT: Adjust the actions accordingly if the DNS provider is not Cloudflare.

Login to [Cloudflare](https://dash.cloudflare.com/login), click on your domain name, and then navigate to the `DNS` menu. Click the [+Add record] button to open the record input form.

Create _CNAME_ aliases (bolded) for the following subdomains:

- **proxy**.yourdomain.com (Proxy dashboard)
- **git**.yourdomain.com (Git server)
- **registry**.yourdomain.com (Docker registry)
- **registryui**.yourdomain.com (Docker registry ui)
- **packages**.yourdomain.com (packages registry)
- **vault**.yourdomain.com (secret/key vault server)
- **ci**.yourdomain.com (continues integration/build server)
- **project**.yourdomain.com (project management tool)

> WARNING: Do not forget to disable the http proxy for all of the subdomains as it is described [here](#turn-off-http-proxy)

Depending on the TTL value, it may take certain time for the change to take effect, keep `ping`-ing the subdomains periodically to verify the result.


## Services

Shallow clone this repository:

```
$ sudo git clone --depth=1 https://github.com/shrideio/shoebox $REPO_ROOT
```

Change the the `*.sh` scripts file mode to `execute`:

```
$ sudo find $REPO_ROOT -type f -name "*.sh" -exec chmod +x {} \;
```


### SSL Proxy Setup

For routing all requests to our services using https, we will be using traefik.

Check if `$SHOEBOX_ROOT` and `$YOUR_DOMAIN` are set before running the script.

Run the proxy container setup script and start the proxy docker container:

```
$ cd $REPO_ROOT/src/proxy/
$ sudo ./proxy_containers_setup.sh $SHOEBOX_ROOT $YOUR_DOMAIN 
$ docker-compose up -d
```

Verify that the container is up by using the `docker ps` command.

The user name and the password for the basic auth for the proxy dashboard that can be access through `proxy.yourdomain.com`
exists in `$SHOEBOX_ROOT/proxy-traefik/secrets.ini`


### Containers Infrastructure

`setup_containers.sh` creates directories for container volume mounts, generates `.evn` files from `env.tmpl` files and copies configuration files (i.e. Vault and Consul) to service working directories if necessary. The script requires two input parameters, first for the services root directory and second for a domain name.

Check if `$SHOEBOX_ROOT` and `$YOUR_DOMAIN` are set before running the script.

```
$ echo $SHOEBOX_ROOT
$ echo $YOUR_DOMAIN
```

Run the following command to prepare the necessary infrastructure for docker containers.

```
$ sudo $REPO_ROOT/src/setup_containers.sh $SHOEBOX_ROOT $YOUR_DOMAIN
```

Verifying the created directories structure,

```
$ sudo ls -R $SHOEBOX_ROOT
```

then check if the placeholders have been replaced on a sample file (i.e. git/.env).

```
$ sudo cat $REPO_ROOT/src/git/.env
```

> IMPORTANT: The following information is provided for troubleshooting purposes only and is not supposed to be used in a regular circumstance.

The setup is split into a batch of scripts per service where each script can be run separately if necessary. The input for all of the scripts matches the following pattern.

```
$ sudo $REPO_ROOT/src/[service]_containers_setup.sh $SHOEBOX_ROOT $YOUR_DOMAIN [port-prefix]
```

> INFO: [port-prefix] for a particular service can be found in `ports_prefix.ini`.

- [git_containers_setup.sh](/src/git/git_containers_setup.sh) - Git server
- [vault_containers_setup.sh](/src/vault/vault_containers_setup.sh) - key/secret vault
- [packages_containers_setup.sh](/src/packages/packages_containers_setup.sh) - package registry
- [registry_containers_setup.sh](/src/registry/registry_containers_setup.sh) - Docker registry
- [ci_containers_setup.sh](/src/ci/ci_containers_setup.sh) - continuous integration and continuous delivery
- [project_containers_setup.sh](/src/project/project_containers_setup.sh) - project management tool

### Service Setup

> IMPORTANT: Order matters

1. [Git (Gogs)](/src/git/README.md)
2. [Key/Secret Vault (Vault)](/src/vault/README.md)
3. [Packages (ProGet)](/src/packages/README.md)
4. [Docker Registry](/src/registry/README.md)
5. [Continuous Integration and Continuous Delivery (Drone)](/src/ci/README.md)
6. [Project Management (Taiga)](/src/project/README.md)

### Backup Configuration

:see_no_evil: :hear_no_evil: :speak_no_evil:
