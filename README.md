# Shoebox - minimalistic dev environment on CentOS 7

## Prerequisites

### Tools

> If a text editor and Git client are already installed you may skip to the next section.

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
    
    > It is highly recommended to disable SELinux for avoiding issues when setting up the infrastructure and Docker containers.

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

- #### Install Apache with mod_ssl

    ```
    $ sudo yum install httpd
    $ sudo yum install mod_ssl
    
    $ sudo systemctl enable httpd
    $ sudo systemctl start httpd
    $ sudo systemctl status httpd
    ```

    If Apache has started successfully the output will contain `active (running)`, otherwise check `error_log` and `access_log` at `/var/log/httpd` for troubleshooting.

    Enable `http` and `https` traffic on the firewall.
    ```    
    $ sudo firewall-cmd --permanent --zone=public --add-service=http
    $ sudo firewall-cmd --permanent --zone=public --add-service=https
    $ sudo firewall-cmd --reload
    ```

    If the dns record exists browse to your domain name, otherwise use teh server ip address. If the setup is successful the browser will display the apache welcome page.

- #### Install Docker and Docker Compose

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

### Environment variables

> Review and modify if necessary.

- #### REPO_ROOT 

    The destination path for cloning this repository.

    ```
    $ export REPO_ROOT=/tmp/shoebox
    $ echo $REPO_ROOT
    ```

- #### YOUR_DOMAIN 

    The domain name for the server with hosted services.

    > Do not forget to replace `yourdomain.com` with the actual domain name.

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


## Setup TSL (SSL)

1. Browse to [Apache on CentOS/RHEL 7](https://certbot.eff.org/lets-encrypt/centosrhel7-apache)

2. Follow the *wildcard* instruction up to the *step 6* inclusively.

    - On *Step 2* - running the following command is sufficient.

        ```
        $ sudo yum install epel-release
        ``` 

    - On *Step 3* - [EC2 region](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html). You may want to add more than one region in case one of the servers is down.

    - On *Step 6* - [Cloudflare](https://www.cloudflare.com/) is a DNS provider for the dns challenge. Please check the [DNS providers](https://community.letsencrypt.org/t/dns-providers-who-easily-integrate-with-lets-encrypt-dns-validation/86438) list supporting *Let's Encrypt* and *Certbot* [DNS Plugins](https://certbot.eff.org/docs/using.html#dns-plugins) integrations.

3. Setup *Cloudflare* credentials

    - Create a [Cloudflare account](https://dash.cloudflare.com/sign-up) and receive an API key. The basic plan is free of charge, 

    - Change the name servers at your domain name provider control panel to the Cloudflare's name servers

    - <a name="turn-off-http-proxy"></a>Turn off the HTTP proxy for main and subdomain names. click the cloud icon ![Alt text](/resources/img/http_proxy_on.png?raw=true "HTTP proxy - ON") next to each domain/subdomain name to gray it out ![Alt text](/resources/img/http_proxy_off.png?raw=true "HTTP proxy - OFF").
        > If you forget to disable the http proxy you may receive an obscure error such as `ERR_TOO_MANY_REDIRECTS`

    - Create an ini file for the Cloudflare DNS API client.
        ```
        $ sudo mkdir -p /etc/letsencrypt/renewal/dns
        $ sudo nano /etc/letsencrypt/renewal/dns/cloudflare.ini
        ```

    - Get the API key. Browse `Overview -> Get your API key -> API Tokens -> Global API Key [View]`
    - Replace **email** and **API key** with the actual values and save the file    
        ```
        # Cloudflare API credentials used by Certbot
        dns_cloudflare_email = cloudflare@example.com
        dns_cloudflare_api_key = 0123456789abcdef0123456789abcdef01234567
        ```

4. Run `certbot` with the following parameters to acquire a certificate. The default awaiting value for the `NAME` record to update is 10 seconds. You may want to increase the delay using the `--dns-cloudflare-propagation-seconds` flag
    
    ```
    $ sudo certbot certonly -i apache \
        --dns-cloudflare \
        --dns-cloudflare-credentials /etc/letsencrypt/renewal/dns/cloudflare.ini \
        --dns-cloudflare-propagation-seconds 30 \
        -d $YOUR_DOMAIN \
        -d *.$YOUR_DOMAIN
    ```

    If the certificate is acquired successfuly a similar message to the shown below will be displayed by `certbot`

    ```
    - Congratulations! Your certificate and chain have been saved at:
      /etc/letsencrypt/live/yourdomain.com/fullchain.pem
      Your key file has been saved at:
      /etc/letsencrypt/live/yourdomain.com/privkey.pem
    ```

5. Letsencrypt certificates are issued for 90 days. To keep your certificate up to date you need to configure auto-renewal
    
    - Test the renewal process
        ```
        $ sudo certbot renew --dry-run
        ```
    
    - If the dry run completed successfully create a cron job 
        ```
        $ echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew" | sudo tee -a /etc/crontab > /dev/null
        ```

6. Enable https traffic on port _443_

    - Configure Apache to listen port 443
        
        Open `httpd.conf` for editing.
        ```
        $ sudo nano /etc/httpd/conf/httpd.conf
        ```

        Copy-paste the following lines of configuration to the end of the file and save changes.

        ```
        # Enable https traffic on port 443
        <IfModule mod_ssl.c>
        Listen 443
        </IfModule>
        ```

    - Disable the default ssl configuration
        ```
        $ sudo mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf_
        ```

    - Restart Apache and proceed if no error is reported, otherwise check `error_log` and `access_log` for troubleshooting
        ```
        $ sudo systemctl restart httpd
        ```

7. Create a unified configuration file for enabling ssl on virtual hosts

    - Check if `options-ssl-apache.conf` was successfully created. This file is required for enabling ssl on virtual hosts and referenced by the virtual host configuration files

        ```
        $ sudo ls /etc/letsencrypt
        ```

        The output should contain the file name

    - Append the file with certificate references

        ```
        $ sudo nano /etc/letsencrypt/options-ssl-apache.conf
        ```

    - Copy-paste the following fragment to the end of the file and save changes.

        ```
        # SSL certificate files references
        SSLCertificateFile /etc/letsencrypt/live/@YOUR_DOMAIN/cert.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/@YOUR_DOMAIN/privkey.pem
        SSLCertificateChainFile /etc/letsencrypt/live/@YOUR_DOMAIN/chain.pem
        ```

    - Replace the placeholder with the actual domain name in `letsencrypt.conf`

        ```
        $ sudo sed -i 's|@YOUR_DOMAIN|'"$YOUR_DOMAIN"'|g' /etc/letsencrypt/options-ssl-apache.conf
        ```

        Verify the result
        ```
        $ sudo cat /etc/letsencrypt/options-ssl-apache.conf
        ```

## Virtual hosts

1. Configure subdomain records.

    - Create _CNAME_ aliases (bolded) matching the following names
        - **git**.yourdomain.com (Git server)
        - **registry**.yourdomain.com (Docker registry)
        - **registryui**.yourdomain.com (Docker registry ui)
        - **packages**.yourdomain.com (packages registry)
        - **vault**.yourdomain.com (secret/key vault server)
        - **ci**.yourdomain.com (continues integration/build server)
        - **project**.yourdomain.com (project management tool)

    > Do not forget to disable the http proxy for all of the subdomains as it is described [here](#turn-off-http-proxy)

2. Check if `$YOUR_DOMAIN` and `$REPO_ROOT` are set,

    ```
    $ echo $YOUR_DOMAIN
    $ echo $REPO_ROOT
    ```

    if absent check the [Environment variables](#Environment-variables) section.

3. Run `setup_virtual_hosts.sh` for creating virtual host configuration files.

    > `ports_prefix.ini` contains virtual host to underlying service port mappings. Review and modify if necessary.

    - The following commands will create and copy virtual host configuration files to `/etc/httpd/conf.d`

        ```
        $ sudo $REPO_ROOT/src/setup_virtual_hosts.sh $YOUR_DOMAIN
        ```

    - Run `sudo ls /etc/httpd/conf.d` to check if the virtual host configurations files have been created. The output should contain the following files:
        
        - git.ssl.conf
        - registry.ssl.conf
        - registryui.ssl.conf
        - packages.ssl.conf
        - vault.ssl.conf
        - ci.ssl.conf
        - project.ssl.conf

    - <a id="modify-registry-vhost-config"></a>Modify `registry.ssl.conf` to avoid `docker push` from failing.
        
        Open `registry.ssl.conf` for editing.
        ```
        $ sudo nano /etc/httpd/conf.d/registry.ssl.conf
        ```
        
        Copy-paste the following lines of configuration anywhere in the _<VirtualHost *:443>_ section and save changes.
        ```
        Header add X-Forwarded-Proto "https"
        RequestHeader add X-Forwarded-Proto "https"
        ```

    - Restart Apache `sudo systemctl restart httpd`, and proceed if no error is reported, otherwise, check `error_log` and `access_log` for troubleshooting. Verify if the http server is serving https traffic by browsing to any of the created subdomains.

        Follow the check list:
        - [x] Redirected from `http` to `https`
        - [x] Response is `503 Service Unavailable`

        Proceed if the checks are passed, otherwise, check `error_log` and `access_log` for troubleshooting.

## Services

- #### Setup prerequisites

    The `setup_containers.sh` script creates directories for container volume mounts, generates `.evn` files with matching paths from `env.tmpl` files and copies configuration files if necessary (i.e. Vault and Consul). The setup script requires two input parameters, first for the setup root directory and second for a domain.

    The setup is split into a batch of scripts per service where each script can be run separately if necessary. The input parameters are same for all of the scripts and match the following pattern.

    ```
    sudo $REPO_ROOT/src/[service]_containers_setup.sh [shoebox-root] [domain-name] [port-prefix]
    ```

    - [git_containers_setup.sh](/src/git/git_containers_setup.sh) - Git
    - [vault_containers_setup.sh](/src/vault/vault_containers_setup.sh) - key/secret vault 
    - [packages_containers_setup.sh](/src/packages/packages_containers_setup.sh) - package management system
    - [registry_containers_setup.sh](/src/registry/registry_containers_setup.sh) - Docker registry
    - [ci_containers_setup.sh](/src/ci/ci_containers_setup.sh) - continuous integration/build server
    - [project_containers_setup.sh](/src/project/project_containers_setup.sh) - project management tool

    Review the scripts and modify if necessary before running the full setup script as follows.
    
    ```
    $ sudo $REPO_ROOT/src/setup_containers.sh $SHOEBOX_ROOT $YOUR_DOMAIN
    ```

    Run `sudo ls -R $SHOEBOX_ROOT` for verifying the created directories structure. Verify if placeholders have been replaced on a sample file (i.e. git/.env).
    ```
    $ sudo cat $REPO_ROOT/src/git/.env
    ```

- #### Setup services (order matters)

    1. [Git (Gogs)](/src/git/README.md)
    2. [Key/Secret Vault (Vault)](/src/vault/README.md)
    3. [Packages (ProGet)](/src/packages/README.md)
    5. [Docker Registry](/src/registry/README.md)
    5. [Continuous Integration (Drone)](/src/ci/README.md)
    6. [Project Management (Taiga)](/src/project/README.md)

## Misc

### SMTP relay

A few services require an SMTP relay for sending email notifications. If your domain name service includes a free email address you may want to use the provider's SMTP server, otherwise, there are a few free emailing services with the limited number of message sent per day/month (at least 100 emails a day).

- [SendPulse](https://sendpulse.com/prices/smtp) (12,000/month)
- [Mailgun](https://www.mailgun.com/pricing-options) (10,000/month)
- [Mailjet](https://www.mailjet.com/pricing/) (6,000/month, 200/day)
- [SendGrid](https://sendgrid.com/marketing/sendgrid-services-cro/#pricing-app) (100/day)

### Backup

:see_no_evil: :hear_no_evil: :speak_no_evil:
