# Shoebox - minimalistic dev environment on CentOS 7

## I. Prerequisites

- Install Nano (simple console-based text editor)
    
    ```
    $ sudo yum install nano
    ```
    
    Shortcuts:
    - Save changes: `ctrl` + `x`, `y`
    - Discard changes: `ctrl` + `x`, `n`
    - Cancel: `ctrl` + `x`, `ctrl` + `c`

- Export your domain name as an environment variable
    > Dont foget to replace `yourdomain.com` with the actual domain name
    ```
    $ export YOUR_DOMAIN_COM=yourdomain.com
    ```
    Run `echo $YOUR_DOMAIN_COM`, it should output the actual domain name

## II. Disable SELinux

1. Check SELinux status. It is recommended to disable SELinux for the ease of use of Docker, and the ease of setting up other auxiliary services

    ```
    $ sestatus

    Output
    SELinux status:                 enabled
    ...
    ...
    Current mode:                   enforcing
    ```

2. Disable SELinux permanently by modifying `/etc/selinux/config`
    ```
    SELINUX=disabled
    ```

3. Save the file and reboot

    ```
    $ sudo shutdown -r now
    ```

4. Check SELinux status
    ```
    $ sestatus

    Output
    SELinux status:                 disabled
    ```
    
## III. Install Apache

1. Run
    ```
    $ sudo yum install httpd
    ```

2. Install Apache mod_ssl module
    ```
    $ sudo yum install mod_ssl
    ```

3. Configure to start on boot
    ```
    $ sudo systemctl enable httpd
    ```

4. Start the service and check its status

    ```
    $ sudo systemctl start httpd
    $ sudo systemctl status httpd
    ```
    If the service was started successfuly you will see `active (running)` in the log messages. Otherwise check `error_log` and `access_log` at `/var/log/httpd` for troubleshooting

5. Enable `http` and `https` traffic on the firewall
    ```    
    $ sudo firewall-cmd --permanent --zone=public --add-service=http    
    $ sudo firewall-cmd --permanent --zone=public --add-service=https
    $ sudo firewall-cmd --reload
    ```

5. Browse `yourdomain.com` (assuming that the DNS record has already been set up), you should see the apache default page

## IV. Receive a wildcard SSL certificate and configure auto-renewal

1. Browse to [Apache on CentOS/RHEL 7](https://certbot.eff.org/lets-encrypt/centosrhel7-apache)

2. Follow the *wildcard* instruction up to the *step 6* inclusively.
    - On *step 2* running `yum install epel-release` should be just enough
    - On *step 3* [EC2 region](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html). You may want to add more than one region in case one of the servers is down.
    - On *step 6* **Cloudfalre** is chosen as a DNS provider for the dns challenge. Please consult with the [DNS providers](https://community.letsencrypt.org/t/dns-providers-who-easily-integrate-with-lets-encrypt-dns-validation/86438) list supporting *Let's Encrypt* and *Certbot* [DNS Plugins](https://certbot.eff.org/docs/using.html#dns-plugins) integration. 

3. Setup *Cloudflare* credentials
    - Create a [Cloudflare account](https://dash.cloudflare.com/sign-up), the basic plan is free of charge, and get the api key
    - Change the nameservers at your domain name provider controil panel to the Cloudflare's name servers
    - <a name="turn-off-http-proxy"></a>Turn off the HTTP proxy for main and subdomain names. Click on the cloud icon ![Alt text](/resources/readme/http_proxy_on.PNG?raw=true "HTTP proxy - ON") next to each domain/subdomain name to gray it out ![Alt text](/resources/readme/http_proxy_off.PNG?raw=true "HTTP proxy - OFF").
        > If you forget to disable the http proxy you may receive an obscure error such as `ERR_TOO_MANY_REDIRECTS`
    - Create an ini file for the Cloudflare DNS API client.
        ```
        $ sudo mkdir -p /etc/letsencrypt/renewal/dns
        $ sudo nano /etc/letsencrypt/renewal/dns/cloudflare.ini
        ```
    - Get the API key. Browse `Get your API key -> API Tokens -> Global API Key [View]`
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
        -d $YOUR_DOMAIN_COM \
        -d *.$YOUR_DOMAIN_COM
    ```
    If the certificate is acquired successfuly a similar message to the shown bellow will be displayed by `certbot`

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
        ```
        $ sudo nano /etc/httpd/conf/httpd.conf
        
        ```
        Copy-paste the following piece of configuration to the end of the configuration file and save
        ```        
        # Enable https trafic on port 443
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

7. Create a unified cofiguration file for enabling ssl on virtual hosts

    - Check if `options-ssl-apache.conf` was successfully created. This file is required for enabling ssl on virtual hosts and referenced by the virtual host configuration files
        ```
        $ sudo ls /etc/letsencrypt
        ```
        The output shoud contain the file name
    
    - Append the file with certificate references
        ```
        $ sudo nano /etc/letsencrypt/options-ssl-apache.conf
        ```
    - Copy-paste to the end of the file and save changes
        ```
        # SSL certificate files references
        SSLCertificateFile /etc/letsencrypt/live/yourdomain.com/cert.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/yourdomain.com/privkey.pem
        SSLCertificateChainFile /etc/letsencrypt/live/yourdomain.com/chain.pem
        ```

    - Replace `yourdomain.com` with the actual domain name in `letsencrypt.conf`
        ```
        $ sudo sed -i -e 's/yourdomain.com/'"$YOUR_DOMAIN_COM"'/g' /etc/letsencrypt/options-ssl-apache.conf
        ```
        Verify the result
        ```
        $ sudo cat /etc/letsencrypt/options-ssl-apache.conf
        ```

## V. Configure virtual hosts

1. Install `git`
    ```
    $ sudo yum install git
    ```
    Run `git --version` to confirm that `git` was successfully installed

2. Clone this repository into a local directory
    ```
    $ git clone --depth=1 https://github.com/shrideio/shoebox /tmp/shoebox
    ```

3. Set up subdomains configuration
    - Replace `yourdomain.com` with the actual domain name in the virtual host files
        ```
        $ sudo find /tmp/shoebox/src/apache/conf.d/ -type f -exec sed -i -e 's|yourdomain.com|'"$YOUR_DOMAIN_COM"'|g' {} \;
        ```
         Verify the result on a sample file (i.e. git.ssl.conf)
        ```
        $ sudo cat /tmp/shoebox/src/apache/conf.d/git.ssl.conf
        ```

    -  Copy the modified virtual host files into the working `conf.d` directory
        ```
        $ sudo cp /tmp/shoebox/src/apache/conf.d/* /etc/httpd/conf.d
        ```

    - Restart Apache and proceed if no error is reported, otherwise, check `error_log` and `access_log` for troubleshooting
        ```
        $ sudo systemctl restart httpd
        ```

4. Configure subdomain records
    - Create _CNAME_ aliases (bolded) matching the following names
        - **git**.yourdomain.com (git server)
        - **registry**.yourdomain.com (package and container registry)
        - **ci**.yourdomain.com (continues integration/build server)
        - **project**.yourdomain.com (project management tool)
        - **vault**.yourdomain.com (secret/key vault server)
        > Do not forget to disable the http proxy for all of the subdomains as it is described [here](#turn-off-http-proxy)

    - Verify that the http server is serving https traffic by browsing to any of the created subdomains. Follow the check list:
        - [x] Redirected from `http` to `https`
        - [x] Response is `503 Service Unavailable`

        Proceed if the checks are passed, otherwise, check `error_log` and `access_log` for troubleshooting

## VI. Install Docker and Docker Compose

1. Uninstall old versions
    ```
    $ sudo yum remove docker \
                      docker-client \
                      docker-client-latest \
                      docker-common \
                      docker-latest \
                      docker-latest-logrotate \
                      docker-logrotate \
                      docker-engine
    ```

2.  Install the required packages
    ```
    $ sudo yum install -y yum-utils \
      device-mapper-persistent-data \
      lvm2
    ```

3. Set up the stable repository
    ```
    $ sudo yum-config-manager \
        --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo
    ```

4. Install the latest version of Docker CE and containerd
    ```
    $ sudo yum install docker-ce docker-ce-cli containerd.io
    ```

5. Configure Docker to start on boot
    ```
    $ sudo systemctl enable docker
    ```    

6. Start Docker
    ```
    $ sudo systemctl start docker
    ```

7. Verify that Docker CE is installed correctly by running
    ```
    $ sudo docker run hello-world
    ```
8. Install `docker-compose`
    ```
    $ sudo yum install docker-compose
    ````
    Run `docker-compose --version` to confirm that `docker-compose` was successfully installed

## VII. Set up directories for container volume mounts

`setup_volumes_storage.sh` (can be found in `/src`) creates directories for container volume mounts and replaces placeholders in the `.evn` files with matching path values. `/var/dev` is chosen as a root directory and can be changed by editing `setup_volumes_storage.sh` if necessary.
Please check the content of `setup_volumes_storage.sh` for more information.

Run the following commad to create directories for volume mounts
```
$ sudo chmod +x /tmp/shoebox/src/setup_volumes_storage.sh
$ sudo /tmp/shoebox/src/setup_volumes_storage.sh
```
Run `sudo ls -R /var/dev` for verifying the created directories structure

Verify if the placeholders were replaced on a sample file (i.e. git/.env)
```
$ sudo cat /tmp/shoebox/src/git/.env
```

## VII. Set up SMTP relay

The majority of key servises of the dev environment setup requre an SMTP relay for sending email notifications.
If your domain name service includes a free email address you may want to use the provider's SMTP service, otherwise, 
there are a few email services providing free accounts with the limited number of sent message per day/month (at least 100 emails a day)
- [SendPulse](https://sendpulse.com/prices/smtp) (12,000/month)
- [Mailgun](https://www.mailgun.com/pricing-options) (10,000/month)
- [Mailjet](https://www.mailjet.com/pricing/) (6,000/month, 200/day)
- [SendGrid](https://sendgrid.com/marketing/sendgrid-services-cro/#pricing-app) (100/day)

## VIII. Set up dev environment services
1. [Git (Gogs)](/src/git/README.md)
2. [Packages and Docker registry (Proget)](/src/registry/README.md)
3. [Continuous Integration (Drone)](/src/ci/README.md)
4. [Key/Secret Vault (Vault)](/src/vault/README.md)
5. [Project Managment (Taiga)](/src/project/README.md)