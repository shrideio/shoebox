# Shoebox

![Alt text](/resources/img/shoebox_logo.png?raw=true "Shoebox")

## TL;DR

- Components: Git; CI/CD; Docker Registry; Package Management; Secrets Management; Project Management
- Minimal requirements: CentOS/RHEL 7.0; 2 vCPUs; 2 GB RAM; 20 GB storage; 1 IPv4 address
- Cons: Single machine configuration; Docker support is a MUST for the build pipeline
- Future plans: Add more build configurations; Move to K8s

goto: [Setup outline](#setup-outline)

## What is it?

Shoebox is an all-in-one bundle of tutorials and scripts (shell and docker-compose) for setting up a simple collaborative software development environment. It can be hosted on a VPS or dedicated server as an inexpensive alternative for subscription-based cloud services. Software components used in this setup are either open source or have free versions (some with limitations, please check).

### Components

| Name                                | Vendor                                                            | License                                                                          |
| :---------------------------------- | :---------------------------------------------------------------- | :------------------------------------------------------------------------------- |
| Git Server                          | [Gogs](https://gogs.io/)                                          | [MIT](https://github.com/gogs/gogs/blob/master/LICENSE)                                                                                                                                      |
| Secret Management                   | [Vault](https://www.vaultproject.io/)                             | [MPL-2.0](https://github.com/hashicorp/vault/blob/master/LICENSE)                                                                                                                            |
| Package Management                  | [Ideo Proget](https://inedo.com/proget)                           | [ProGet License Agreement](https://inedo.com/proget/license-agreement) <br /> [Free Edition Limitations](https://docs.inedo.com/docs/proget/administration/license#free-edition-limitations) |
| Docker Registry                     | [Docker Registry](https://docs.docker.com/registry/)              | [Apache-2.0](https://github.com/docker/distribution/blob/master/LICENSE)                                                                                                                     |
| Docker Registry UI                  | [Joxit Docker Registry UI](https://joxit.dev/docker-registry-ui/) | [AGPL-3.0](https://github.com/Joxit/docker-registry-ui/blob/master/LICENSE)                                                                                                                  |
| Continuous Integration and Delivery | [Drone CI](https://drone.io/)                                     | [Drone Non-Commercial License](https://github.com/drone/drone/blob/master/LICENSE) <br /> [Waiver: Individual and Small Business](https://github.com/drone/drone/blob/master/LICENSE#L62) |
| Project Management                  | [Taiga](https://taiga.io/)                                        | [Taiga Backend - AGPL-3.0](https://github.com/taigaio/taiga-back/blob/master/LICENSE) <br /> [Taiga Front - AGPL-3.0](https://github.com/taigaio/taiga-front/blob/master/LICENSE) |


## Why does this exist?

The short answer is [“Those goddamn AWS charges!”](https://www.youtube.com/watch?v=982wFqC03v8).

On a serious note, we believe that even small teams can benefit from using a fully equipped development environment without paying a premium for infrastructural services purchased from cloud service providers.

> INFO: The latter is less actual for open source projects. Usually, most of the tools mentioned in this setup are provided free of charge by major vendors.

And lastly, this setup is an attempt to document and automate the deployment of essential services used when working on a personal project.

## How does it work?

This setup requires a Linux machine with root access and system requirements matching the following:

- Minimal:

  - OS: Linux CentOS/RHEL 7.0
  - CPU: 2 vCPU
  - RAM: 2 GB
  - Storage: 20 GB
  - Network: 1 static IPv4 address

- Recommended:

  - OS: Linux CentOS/RHEL 7.0
  - CPU: 4 vCPU
  - RAM: 4 GB
  - Storage: 20 GB
  - Network: 1 IPv4 address

> INFO: This setup was tested and staged on CentOS 7.0, that is why this OS mentioned as a requirement. However, with minor adjustments, it should work on any other popular Linux distributive.

When it comes to choosing a physical host, there are three options for consideration.

> IMPORTANT: None of the vendors listed below have a sponsorship or advertisement agreement with the authors. Likewise, the authors are not responsible or liable for any damage or inconvenience caused by actions or inactions of the vendors.

1. Rent a Linux VPS.

   There are a few affordable options in a price range of 7 to 15 USD per month. The vendors listed below offer solutions matching or comparable to the system requirements mentioned above and price range.

   - [VPSDime](https://vpsdime.com/)
   - [OVHCloud](https://www.ovh.com/)
   - [Hostinger](https://www.hostinger.com/)
   - [Interserver](https://www.interserver.net/)
   - [Hostnoc](https://hostnoc.com/)
   - [VPSCheap](https://www.vpscheap.net/)
   - [VirMach ](https://virmach.com/)
   - [TheStack](https://portal.thestack.net/)
   - [Kamatera Express](https://www.kamatera.com/)

2. Rent a dedicated server.

   This option is more costly than renting a VPS, however, it provides extra computing power and storage capacity for the premium. Therefore, the dedicated server option can be considered as an expansion path for future growth. There is a limited number of affordable options in a price range of 20 to 30 USD per month (typically the price starts from 50 USD per month). 
   
   > WARNING: When choosing a dedicated server it is recommended to avoid renting significantly outdated hardware. Old hardware can potentially yield less performance than a VPS with lesser cost.

   - [Nocix](https://www.nocix.net/)
   - [Wholesale Internet](https://www.wholesaleinternet.net/)
   - [Server Room](https://www.serverroom.net/)
   - [Primcast](https://www.primcast.com/)

3. Run a server on-premises.

Either way, be mindful of the law of diminishing returns. For example, the premium paid for extra storage on a VPS may equalize the VPS rental cost with the dedicated server monthly fee. Long story short, do back-of-the-napkin-math.

> INFO: Check https://serverbench.net/ for open source benchmark tools


## People

### Special thanks [A -> Z]

  - [Alex Muradov](https://github.com/alik116)
  - [Melissa Kendall](https://github.com/melissakendall)
  - [Valentyna Akulova](https://github.com/Valentynaa)

### Authors [A -> Z]

  - [Bahram Aliyev](https://github.com/bahram-aliyev)
  - [Michael Roizman](https://github.com/mich4xD)

## Support

We will do our best to maintain the documentation and keep the scripts up-to-date, and continue adding new CI configurations for different technologies as needed. If you have a question or have found an issue feel free to create a ticket [here](https://github.com/shrideio/shoebox/issues), we will respond as soon as possible.
  

## Q/A

- How to help or contribute?

  We are no Linux gurus, Docker experts, or professional technical writers, so you are more than welcome to contribute! File an issue ticket or even better open a pull request, we will do our best to respond as soon as possible. Constructive criticism is highly appreciated.

- Any caveats?

  Firstly, it is a single machine configuration incapable of running on a cluster. That potentially may become a problem when simultaneously running build pipelines can potentially degrade the performance of the other services. This deficiency should be resolved once this setup is made deployable to a Kubernetes cluster.

  Secondly, the technology of your choice must support Docker containerization for using the Drone build pipeline. If it does not, consider using alternatives such as [Jenkins CI](https://jenkins.io/) or [Concourse](https://concourse-ci.org/). No setup scripts or documentation are provided for the alternative CI services currently.

  And lastly, the build pipeline is biased toward .NET Core. Please feel free to contribute and add pipeline configurations for other technologies.

- What is next?

  As it is mentioned earlier, adding Kubernetes support is a high priory task on the list. However, we need to acquaint ourselves with the technology first.

- Shoebox - why the name?

  ...cus' it has something in it to getcha runnin'! :checkered_flag: :running: :boom:


## Setup outline

- [Tools](#tools)
  - [Nano](#nano)
  - [Git client](#git-client)
  - [Httpd tools](#httpd-tools)
- [Infrastructure](#infrastructure)
  - [Disable SELinux](#disable-selinux)
  - [Docker infrastructure](#docker-infrastructure)
  - [SMTP relay](#smtp-relay)
- [Network](#network)
  - [DNS provider](#dns-provider)
  - [Subdomain Records](#subdomain-records)
  - [DNS API client](#dns-api-client)
- [Services](#services)
  - [Environment variables](#environment-variables)
  - [Setup scripts](#setup-scripts)
  - [Reverse proxy](#reverse-proxy)
  - [Containers infrastructure](#containers-infrastructure)
  - [Services setup](#services-setup)


## Tools

### Nano

> INFO: Simple console-based text editor

```
$ sudo yum install -y nano
```

Shortcuts:

- Save changes: `ctrl` + `x`, `y`
- Discard changes: `ctrl` + `x`, `n`
- Cancel: `ctrl` + `x`, `ctrl` + `c`

### Git client

```
$ sudo yum install -y git
$ sudo git --version # to confirm `git` is successfully installed
```

### Httpd tools

> INFO: Includes the `htpasswd` util required for generating hashed passwords.

```
$ sudo yum install -y httpd-tools
```


## Infrastructure

### Disable SELinux

> IMPORTANT: It is highly recommended to disable SELinux for avoiding issues with infrastructure services and Docker containers.

Check SELinux status.

```
$ sudo sestatus
```

Output:

```
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

Reboot.

```
$ sudo shutdown -r now
```

Check SELinux status, it is expected to be `disabled`.

```
$ sudo sestatus
```

Output:

```
SELinux status:                 disabled
```

### Docker infrastructure

- Install Docker

  ```
  $ sudo yum remove \
      docker \
      docker-client \
      docker-client-latest \
      docker-common \
      docker-latest \
      docker-latest-logrotate \
      docker-logrotate \
      docker-engine

  $ sudo yum install -y \
      yum-utils \
      device-mapper-persistent-data \
      lvm2

  $ sudo yum-config-manager --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo

  $ sudo yum install -y docker-ce docker-ce-cli containerd.io

  $ sudo systemctl enable docker
  $ sudo systemctl start docker
  ```
  Run the following command create and run a test container. The output should contain _Hello from Docker!_.

  ```
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

### SMTP relay

Certain services in this setup require an SMTP relay for sending email notifications. If your DNS provider includes a free email address, you may want to use the provider's SMTP server. Otherwise, there are a few free emailing services with a limited number of messages sent per day/month (at least 100 emails a day).

- [SendPulse](https://sendpulse.com/prices/smtp) (12,000/month)
- [Mailgun](https://www.mailgun.com/pricing-options) (10,000/month)
- [Mailjet](https://www.mailjet.com/pricing/) (6,000/month, 200/day)
- [SendGrid](https://sendgrid.com/marketing/sendgrid-services-cro/#pricing-app) (100/day)


## Network

### DNS provider

[Cloudflare](https://www.cloudflare.com/) is used as the default DNS provider for this setup. It provides a DNS API that is used by Certbot for proving the domain name ownership when acquiring an SSL/TLS certificate.

> IMPORTANT: If Cloudflare is not an option, there are a few more [DNS providers compatible with Certbot](https://community.letsencrypt.org/t/dns-providers-who-easily-integrate-with-lets-encrypt-dns-validation/86438). Adjust the following actions according to the DNS provider of your choice.

Create a [Cloudflare account](https://dash.cloudflare.com/sign-up), the basic plan is free of charge. Add your domain name as a website and complete the verification process for proving the domain name ownership.

Change the name servers in the control panel of your domain name provider to the Cloudflare name servers, the name servers can be found at `DNS -> Cloudflare nameservers`. Depending on the TTL set in the DNS control panel it may take some time for the change to take effect, keep `ping`-ing the domain name periodically.


### Subdomain records

Navigate to the `DNS` menu, Click the [+Add record] button to open the record input form.

Create _CNAME_ aliases (bolded) for the following subdomains:

- **proxy**.yourdomain.com (Proxy dashboard)
- **git**.yourdomain.com (Git server)
- **registry**.yourdomain.com (Docker registry)
- **registryui**.yourdomain.com (Docker registry ui)
- **packages**.yourdomain.com (packages registry)
- **vault**.yourdomain.com (secret/key vault server)
- **ci**.yourdomain.com (continues integration/build server)
- **project**.yourdomain.com (project management tool)

Disable the HTTP proxy for main and subdomain names. Click the cloud icon ![Alt text](/resources/img/http_proxy_on.png?raw=true "HTTP proxy - ON") next to each domain/subdomain name to gray it out ![Alt text](/resources/img/http_proxy_off.png?raw=true "HTTP proxy - OFF").

> WARNING: If the http proxy is not disabled it causes an obscure error response such as _ERR_TOO_MANY_REDIRECTS_.

Depending on the TTL value, it may take some time for the change to take effect, keep `ping`-ing the subdomains periodically to verify the result.


### DNS API client

Cloudflare API credentials are used by Certbot for proving the domain name ownership when acquiring an HTTPS certificate from [Let’s Encrypt](https://letsencrypt.org/).

Get the DNS API key. In the Cloudflare panel browse to `Overview -> Get your API token -> API Tokens -> Global API Key [View]`.

Export the following environment variables with matching values of Cloudflare email (login) and API key, and Let's Encrypt email.

```
$ export CLOUDFLARE_EMAIL=[cloudflare-email]
$ export CLOUDFLARE_API_KEY=[cloudflare-api-key]
$ export LETSENCRYPT_EMAIL=[letsencrypt-email]
```

Create an ini file for the Cloudflare DNS API client.

```
$ sudo mkdir -p /etc/cloudflare
$ export CLOUDFLARE_API_INI=/etc/cloudflare/cloudflare-api.ini
$ sudo touch $CLOUDFLARE_API_INI
```

Execute the following commands to update the ini file with the Cloudflare credentials and Let's Encrypt email.

```
$ echo "CLOUDFLARE_EMAIL=$CLOUDFLARE_EMAIL" >> $CLOUDFLARE_API_INI
$ echo "CLOUDFLARE_API_KEY=$CLOUDFLARE_API_KEY" >> $CLOUDFLARE_API_INI
$ echo "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" >> $CLOUDFLARE_API_INI
```

Run `$ sudo cat $CLOUDFLARE_API_INI` to verify the result.


## Services


### Environment variables

Set the following environment variables:

> INFO: Review and modify if necessary.

- `REPO_ROOT`

    The destination path for cloning this repository.

    ```
    $ export REPO_ROOT=/tmp/shoebox
    $ echo $REPO_ROOT
    ```

- `YOUR_DOMAIN`

    The domain name for the server with hosted services.

    > IMPORTANT: Do not forget to replace `yourdomain.com` with the actual domain name.

    ```
    $ export YOUR_DOMAIN=[yourdomain.com]
    $ echo $YOUR_DOMAIN
    ```

- `SHOEBOX_ROOT`

    The root directory where the data and configuration files of the services are stored.

    ```
    $ export SHOEBOX_ROOT=/var/shoebox
    $ echo $SHOEBOX_ROOT
    ```


### Setup scripts

Shallow clone this repository.

```
$ sudo git clone --depth=1 https://github.com/shrideio/shoebox $REPO_ROOT
```

Change the `*.sh` scripts file mode to `execute`.

```
$ sudo find $REPO_ROOT -type f -name "*.sh" -exec chmod +x {} \;
```


### Reverse proxy

[Traefik](https://docs.traefik.io/) is used as a reverse proxy for routing http traffic in and out of the service containers. Besides, it automates acquiring an SSL/TLS certificate from Let's Encrypt.

Check if `$SHOEBOX_ROOT`, `$YOUR_DOMAIN`, and `$CLOUDFLARE_API_INI` are set before running the script.

```
$ echo $SHOEBOX_ROOT
$ echo $YOUR_DOMAIN
$ echo $CLOUDFLARE_API_INI
```

Run the following script to create the `proxy` container.

```
$ cd $REPO_ROOT/src/proxy/
$ sudo ./proxy_containers_setup.sh $SHOEBOX_ROOT $YOUR_DOMAIN $CLOUDFLARE_API_INI
$ sudo docker-compose up -d
```

Run `$ sudo docker ps | grep proxy` to verify if the `proxy` container is up and running.

The credentials for accessing the proxy dashboard at `proxy`.yourdomain.com are printed to the console and can be found in `$SHOEBOX_ROOT/proxy-traefik/secrets.ini`.

Enable `http` and `https` traffic on the firewall.

```
$ sudo firewall-cmd --zone=public --permanent --add-service=http
$ sudo firewall-cmd --zone=public --permanent --add-service=https
$ sudo firewall-cmd --reload
```

Navigate to `http://proxy.`_yourdomain.com_ to verify if the request is automatically redirected from `http` to `https` and the TLS certificate is valid. If the certificate is invalid run `$ sudo docker logs proxy` to check the container logs for troubleshooting.


### Containers infrastructure

The `setup_containers.sh` script creates directories for container volume mounts, generates `.evn` files, and copies configuration files (i.e. for Vault and Consul) to service working directories if necessary. In addition, it generates secrets for service or database users and stores them in the `secretes.ini` files in service working directories.

> IMPORTANT: Once the secrets are created, they remain intact, therefore `setup_containers.sh` can be run multiple times without modifying credentials.

The `ports_prefix.ini` file at the repository root (`$REPO_ROOT`) defines the prefixes for ports assigned to containers. The port definitions are hard-coded in the [service]-docker-compose.yml files, however, the port prefixes can be modified in `ports_prefix.ini` before running `setup_containers.sh`.

`setup_containers.sh` requires two input parameters, first for the services root directory and second for a domain name. Check if `$SHOEBOX_ROOT` and `$YOUR_DOMAIN` are set before running the script.

```
$ echo $SHOEBOX_ROOT
$ echo $YOUR_DOMAIN
```

Run the following command to prepare the necessary infrastructure for docker containers.

```
$ sudo $REPO_ROOT/src/setup_containers.sh $SHOEBOX_ROOT $YOUR_DOMAIN
```

Verify the directories are created.

```
$ sudo ls $SHOEBOX_ROOT
```

The output should contain the following list with service working directories:

```
ci-drone git-gogs packages-proget project-taiga prox-traefik registry-docker vault-hashicorp 
```

Verify if the placeholders are replaced by viewing the content of a sample `.env` file (i.e. git/.env).

```
$ sudo cat $REPO_ROOT/src/git/.env
```

If needed to rerun the script for the specific service, run the associated bash script in the service source subdirectory as follows:

```
$ sudo $REPO_ROOT/src/[service-name]/[service-name]_containers_setup.sh $SHOEBOX_ROOT $YOUR_DOMAIN
```

where _[service-name]_ is one of the following: `ci`, `git`, `packages`, `project`, `registry`, `vault`.

### Service setup

Each service is provided with a tutorial describing the steps required for initial setup and usage examples for executing routine tasks in the future. The key outcome of this setup is enabling the CI/CD service to run automated builds by utilizing the rest of the components of this setup.

> IMPORTANT: Order matters.

1. [Git (Gogs)](/src/git/README.md)
2. [Key/Secret Vault (Vault)](/src/vault/README.md)
3. [Packages (ProGet)](/src/packages/README.md)
4. [Docker Registry](/src/registry/README.md)
5. [Continuous Integration and Continuous Delivery (Drone)](/src/ci/README.md)
6. [Project Management (Taiga)](/src/project/README.md)