# Shoebox - minimalistic dev environment on CentOS 7

## Outline

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
    - [Virtual Hosts](#virtual-hosts)
        - [Configuration files](#create-vhost-configs)
        - [Docker Registry vhost configuration](#amend-docker-registry-vhost)
        - [Verify http to https redirect](#vhost-config-verify-result)
    - [Containers Infrastructure](containers-infrastructure)
    - [Service Setup](services-setup)
    - [Backup Configuration](backup-configuration)

## Prerequisites

### Tools

> INFO: If a text editor and Git client are already installed you may skip to the next section.

- #### Nano

    Simple console-based text editor.

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
    
    > IMPORTANT: It is highly recommended to disable SELinux for avoiding issues when setting up the infrastructure and Docker containers.

    Check SELinux status.
    ```
    $ sestatus

    Output
    SELinux status:                 enabled
    ...
    ...
    Current mode:                   enforcing
    ```

    If SELinux is `enabled` follow the instruction to disable it, otherwise continue to the next section.
    
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

- #### Apache and mod_ssl

    Install Apache and mod_ssl and register the former as a system service.

    ```
    $ sudo yum install httpd
    $ sudo yum install mod_ssl
    
    $ sudo systemctl enable httpd
    $ sudo systemctl start httpd
    $ sudo systemctl status httpd
    ```

    <a href="troubleshoot-apache"></a>If Apache has successfully started the `status` command  output will contain `active (running)`, otherwise check `error_log` and `access_log` at `/var/log/httpd` for troubleshooting.

    Enable `http` and `https` traffic on the firewall.
    ```    
    $ sudo firewall-cmd --permanent --zone=public --add-service=http
    $ sudo firewall-cmd --permanent --zone=public --add-service=https
    $ sudo firewall-cmd --reload
    ```

    If the dns record exists browse to your domain name, otherwise use teh server ip address. If the setup is successful the browser will display the apache welcome page.

- #### Docker and Docker Compose

    Install Docker and Docker Compose.

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
    $ sudo docker run hello-world # to verify if  Docker CE is successfully installed

    $ sudo yum install docker-compose
    $ sudo docker-compose --version # to confirm that `docker-compose` is successfully installed
    ```

### SMTP relay

Certain services in this setup require an SMTP relay for sending email notifications. If your DNS provider includes a free email address you may want to use the provider's SMTP server, otherwise, there are a few free emailing services with a limited number of message sent per day/month (at least 100 emails a day).

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
    $ export REPO_ROOT=/var/shoebox
    $ echo $REPO_ROOT
    ```

## Network

### DNS Provider

The DNS providers a DNS API that is used by Certbot for proofing the domain name ownership for the SSL certificate acquisition.
[Cloudflare](https://www.cloudflare.com/) is used as the default DNS provider for this setup.

> IMPORTANT: If Cloudflare is not an option there is a number of [DNS providers compatible with Certbot](https://community.letsencrypt.org/t/dns-providers-who-easily-integrate-with-lets-encrypt-dns-validation/86438). In this case the actions given below must be adjusted accordingly.

> WARNING: If the selected DNS provider is not compatible with Certbot the **Network** section may be deemed incompatible, and certificate acquisition and renewal setup must be conducted independently.

1. <a name="cloudflare-account-setup"></a> Create a [Cloudflare account](https://dash.cloudflare.com/sign-up), the basic plan is free of charge. Add your domain name as a website and complete the verification process for proving the domain name ownership.

2. <a name="cloudflare-name-servers"></a> Change the name servers in the control panel of your domain name provider to the Cloudflare's name servers. To get the name servers navigate to `DNS -> Cloudflare nameservers`. Depending on the TTL set in the domain name provider control panel it may take some time for the change to take effect, keep `ping`-ing the domain name periodically.

3. <a name="turn-off-http-proxy"></a> Turn off the HTTP proxy for main and subdomain names. click the cloud icon ![Alt text](/resources/img/http_proxy_on.png?raw=true "HTTP proxy - ON") next to each domain/subdomain name to gray it out ![Alt text](/resources/img/http_proxy_off.png?raw=true "HTTP proxy - OFF").

    > WARNING: If the http proxy is not disabled it will cause an obscure error response such as `ERR_TOO_MANY_REDIRECTS`.

4. <a name="cloudflare-dns-api-client"></a> Cloudflare DNS API client is used by Certbot for proofing the domain name ownership when acquiring an HTTPS certificate from [Let’s Encrypt](https://letsencrypt.org/).

    > INFO: Adjust the actions accordingly if the DNS provider is not Cloudflare.

    Create an ini file for the Cloudflare DNS API client,

    ```
    $ sudo mkdir -p /etc/letsencrypt/renewal/dns
    $ sudo nano /etc/letsencrypt/renewal/dns/cloudflare.ini
    ```

    and copy-paste the following fragment.

    ```
    # Cloudflare API credentials used by Certbot
    dns_cloudflare_email = @CLOUDFLARE_EMAIL
    dns_cloudflare_api_key = @CLOUDFLARE_API_KEY
    ```

    Get the DNS API key. In the Cloudflare panel browse to `Overview -> Get your API token -> API Tokens -> Global API Key [View]`.

    Replace the placeholders and run the following commands to set values.

    - [cloudflare_email] - the Cloudflare login
    - [cloudflare_api_key] - the Global API key
    <br/><br/>
    ```
    $ sudo sed -i 's|@CLOUDFLARE_EMAIL$|'[cloudflare_email]'|g' /etc/letsencrypt/renewal/dns/cloudflare.ini
    $ sudo sed -i 's|@CLOUDFLARE_API_KEY$|'[cloudflare_api_key]'|g' /etc/letsencrypt/renewal/dns/cloudflare.ini
    ```

    Run `$ sudo cat /etc/letsencrypt/renewal/dns/cloudflare.ini` to verify the result.

### Subdomain Records

> IMPORTANT: Adjust the actions accordingly if the DNS provider is not Cloudflare.

Login to [Cloudflare](https://dash.cloudflare.com/login), click on your domain name and then navigate to `DNS`. Click the `+Add record` button to open the record input form.

Create _CNAME_ aliases (bolded) matching the following subdomains

- **git**.yourdomain.com (Git server)
- **registry**.yourdomain.com (Docker registry)
- **registryui**.yourdomain.com (Docker registry ui)
- **packages**.yourdomain.com (packages registry)
- **vault**.yourdomain.com (secret/key vault server)
- **ci**.yourdomain.com (continues integration/build server)
- **project**.yourdomain.com (project management tool)

> WARNING: Do not forget to disable the http proxy for all of the subdomains as it is described [here](#turn-off-http-proxy)

Depending on the TTL value it may take certain time for the change to take effect, keep `ping`-ing the subdomains periodically to verify the result.

### SSL Setup

Certbot is used as the default Let’s Encrypt client in this setup.

> INFO:  Check the [DNS providers](https://community.letsencrypt.org/t/dns-providers-who-easily-integrate-with-lets-encrypt-dns-validation/86438) list supporting *Let's Encrypt* for other options. 

> IMPORTANT: If a different Let’s Encrypt client is selected the certificate has to be acquired independently and this section can be ignored.

1. Browse to [Apache on CentOS/RHEL 7](https://certbot.eff.org/lets-encrypt/centosrhel7-apache)

2. Follow the **wildcard** instruction up to the *step 6* inclusively.

    - On *Step 2* - running the following command is sufficient `$ sudo yum install epel-release`.

    - On *Step 3* - [EC2 region](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html). You may want to add more than one region in case one of the servers is down.

    - On *Step 6* - If Cloudflare is not selected as a DNS provider please adjust the command accordingly to possible options given in the [DNS Plugin list](https://certbot.eff.org/docs/using.html#dns-plugins).

4. Run `certbot` with the following parameters to acquire a certificate. The default pending time for `NAME` record update is 10 seconds. It may be increased using the `--dns-cloudflare-propagation-seconds` if the command fails due to a timeout.

    > INFO: Do not forget to adjust the command if the DNS provider is not Cloudflare.

    ```
    $ sudo certbot certonly -i apache \
        --dns-cloudflare \
        --dns-cloudflare-credentials /etc/letsencrypt/renewal/dns/cloudflare.ini \
        --dns-cloudflare-propagation-seconds 30 \
        -d $YOUR_DOMAIN \
        -d *.$YOUR_DOMAIN
    ```

    Certbot will display the path to the acquired certificate and key files as shown below if the command succeeded.

    ```
    - Congratulations! Your certificate and chain have been saved at:
      /etc/letsencrypt/live/yourdomain.com/fullchain.pem
      Your key file has been saved at:
      /etc/letsencrypt/live/yourdomain.com/privkey.pem
    ```

5. Let’s Encrypt certificates are issued for 90 days. It is recommended to configure auto-renewal to keep the certificate up-to-date.

    Test the renewal process.

    ```
    $ sudo certbot renew --dry-run
    ```

    If dry run completed successfully configure a cron job.

    ```
    $ echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew" | sudo tee -a /etc/crontab > /dev/null
    ```

6. Enable https traffic on port _443_

    Configure Apache to listen port 443, open `httpd.conf` for editing,

    ```
    $ sudo nano /etc/httpd/conf/httpd.conf
    ```

    then copy-paste the following lines of configuration to the end of the file and save changes.

    ```
    # Enable https traffic on port 443
    <IfModule mod_ssl.c>
    Listen 443
    </IfModule>
    ```

    Disable the default ssl configuration

    ```
    $ sudo mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf_
    ```

    and restart Apache. 
    
    ```
    $ sudo systemctl restart httpd
    ```

    Proceed if no error is reported, otherwise check `error_log` and `access_log` for troubleshooting.


7. Create a unified configuration file for enabling ssl on virtual hosts

    Check if `options-ssl-apache.conf` was successfully created. This file is required for enabling SSL on virtual hosts and referenced by virtual host configuration files.

    ```
    $ sudo ls /etc/letsencrypt
    ```

    The output should contain the file name.

    Append the file,

    ```
    $ sudo nano /etc/letsencrypt/options-ssl-apache.conf
    ```

    and copy-paste the following fragment to the end of the file and save changes.

    ```
    # SSL certificate files references
    SSLCertificateFile /etc/letsencrypt/live/@YOUR_DOMAIN/cert.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/@YOUR_DOMAIN/privkey.pem
    SSLCertificateChainFile /etc/letsencrypt/live/@YOUR_DOMAIN/chain.pem
    ```

    Replace the placeholder with the actual domain name in `letsencrypt.conf`

    ```
    $ sudo sed -i 's|@YOUR_DOMAIN|'"$YOUR_DOMAIN"'|g' /etc/letsencrypt/options-ssl-apache.conf
    ```

    and verify the result.

    ```
    $ sudo cat /etc/letsencrypt/options-ssl-apache.conf
    ```

## Services

Shallow clone this repository,

```
$ sudo git clone --depth=1 https://github.com/shrideio/shoebox $REPO_ROOT
```

and change the the `*.sh` scripts file mode to `execute`.

```
$ sudo find $REPO_ROOT -type f -name "*.sh" -exec chmod +x {} \;
```

### Virtual Hosts

Create virtual host configuration files matching the [subdomains](#subdomain-records) for redirecting the http traffic to underlying services.

1. <a id="create-vhost-configs"></a> `setup_virtual_hosts.sh` generates virtual host configuration files and copies them to `/etc/httpd/conf.d`. 

    The script requires a domain name as a parameter, check if `$YOUR_DOMAIN` is set before running it.

    ```
    $ echo $YOUR_DOMAIN
    ```

    Run the following command to create virtual host configuration files for the [subdomains](#create-subdomain-records).

    > INFO: `ports_prefix.ini` contains virtual host to underlying service port mappings, review and modify if necessary.

    ```
    $ sudo $REPO_ROOT/src/setup_virtual_hosts.sh $YOUR_DOMAIN
    ```

    Check if the virtual host configuration files have been created.
    
    ```
    $ sudo ls /etc/httpd/conf.d
    ```

    The output is expected to contain the following file names:

    ```
    - git.ssl.conf
    - registry.ssl.conf
    - registryui.ssl.conf
    - packages.ssl.conf
    - vault.ssl.conf
    - ci.ssl.conf
    - project.ssl.conf
    ```

2. <a id="amend-docker-registry-vhost"></a> Modify `registry.ssl.conf` to prevent `docker push` from failing.

    Open the configuration file for editing for editing,

    ```
    $ sudo nano /etc/httpd/conf.d/registry.ssl.conf
    ```

    then copy-paste the text given below anywhere in between the _<VirtualHost *:443>...</VirtualHost *:443>_ section and save changes.

    ```
    Header add X-Forwarded-Proto "https"
    RequestHeader add X-Forwarded-Proto "https"
    ```

3. <a id="vhost-config-verify-result"></a> Restart Apache,

    ```
    $ sudo systemctl restart httpd
    ```
    
    Verify if the http server is serving https traffic by browsing to any of the created subdomains and following the check list:

    - [x] Redirect from `http` to `https` works
    - [x] Response is `503 Service Unavailable`

    Proceed if the checks are passed, otherwise, check the service status and logs as described [here](#troubleshoot-apache).

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
- [ci_containers_setup.sh](/src/ci/ci_containers_setup.sh) - Continuous Integration and Continuous Delivery
- [project_containers_setup.sh](/src/project/project_containers_setup.sh) - project management tool

### Service Setup 

> IMPORTANT: Order matters

1. [Git (Gogs)](/src/git/README.md)
2. [Key/Secret Vault (Vault)](/src/vault/README.md)
3. [Packages (ProGet)](/src/packages/README.md)
5. [Docker Registry](/src/registry/README.md)
5. [Continuous Integration (Drone)](/src/ci/README.md)
6. [Project Management (Taiga)](/src/project/README.md)

### Backup Configuration

:see_no_evil: :hear_no_evil: :speak_no_evil: