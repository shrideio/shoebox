# Shoebox - minimalistic dev environment on CentOS 7

## Prerequisites

- Install Nano (smple concole based text editor)
    
    ```
    $ sudo yum install nano
    ```
    
    Shortcuts:
    - Save changes: `ctrl` + `x`, `y`
    - Discard changes: `ctrl` + `x`, `n`
    - Cancel: `ctrl` + `x`, `ctrl` + `c`

- Export your domain name as an environment varaible
    > Dont foget to replace `yourdomain.com` with the actual domain name
    ```
    $ export YOUR_DOMAIN_COM=yourdomain.com
    ```
    Run `echo $YOUR_DOMAIN_COM`, it should display the actual domain name

## Disable SELinux

1. Check SELinux status. It is recommended to disable SELinux for the ease of use of Docker, and for installing and setting up other axilary services

    ```
    $ sestatus

    Output
    SELinux status:                 enabled
    ...
    ...
    Current mode:                   enforcing
    ```

2. Disable SELinux permamently by modifying `/etc/selinux/config`
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
    
## Install Apache

1. Run
    ```
    $ sudo yum install httpd
    ```

2. Configure to start on boot
    ```
    $ sudo systemctl enable httpd
    ```

3. Start the service and check its status

    ```
    $ sudo systemctl start httpd
    $ sudo systemctl status httpd
    ```
    You will see `active (running)` when the service is running

4. Open `80` and `443` ports
    ```
    $ sudo firewall-cmd --permanent --add-port=80/tcp
    $ sudo firewall-cmd --permanent --add-port=433/tcp
    $ sudo firewall-cmd --reload
    ```

5. Browse `yourdomain.com` (assuming that the dns record has alredy been set up), you should see the apache default page

## Receive an SSL certificate and configure auto renewal

1. Browse to [Apache on CentOS/RHEL 7](https://certbot.eff.org/lets-encrypt/centosrhel7-apache)

2. Follow the *default* instruction
    - On *step 2* running `yum install epel-release` should be just enough
    - On *step 3* [EC2 region](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html). You may want to add more than one region in case one of the servers is down.
    - Follow the instruction up to *step 4*

3. You will need to create cretificate [pre and post validation hooks](https://certbot.eff.org/docs/using.html?#pre-and-post-validation-hooks) for certificate renewal
    
    - Create a directory for token verification
        ```
        $ sudo mkdir -p /var/www/letsencrypt/.well-known/acme-challenge
        ```
    
    - Create a virtual host configuration for the verification link alias
        ```
        $ nano /etc/httpd/conf.d/letsencrypt.conf
        ```
        Copy-paste & save
        ```
        <VirtualHost *:80>
        ServerName yourdomain.com
        DocumentRoot /var/www/letsencrypt/.well-known/acme-challenge
        </VirtualHost>

        Alias /.well-known/acme-challenge/ "/var/www/letsencrypt/.well-known/acme-challenge/"
        <Directory "/var/www/letsencrypt/.well-known/acme-challenge/">
            AllowOverride None
            Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
            Require method GET POST OPTIONS
        </Directory>
        ```
    - Repalce `yourdomain.com` with the actual domain name in `letsencrypt.conf` 
        ```
        $ sudo sed -i -e 's/yourdomain.com/'"$YOUR_DOMAIN_COM"'/g' /etc/httpd/conf.d/letsencrypt.conf
        ```
    - Restart Apache
        ```
        systemctl restart httpd
        ```

    - Create authenticator.sh
        ```
        $ sudo mkdir -p /etc/letsencrypt/renewal-hooks/pre/http 
        $ sudo nano /etc/letsencrypt/renewal-hooks/pre/http/authenticator.sh        
        ```
        Copy-paste & save
        ```
        #!/bin/bash
        echo $CERTBOT_VALIDATION > /var/www/letsencrypt/.well-known/acme-challenge/$CERTBOT_TOKEN
        ```
        Run
        ```
        $ sudo chmod +x /etc/letsencrypt/renewal-hooks/pre/http/authenticator.sh
        ```
    
    - Create cleanup.sh
        ```
        $ sudo mkdir -p /etc/letsencrypt/renewal-hooks/post/http
        $ sudo nano /etc/letsencrypt/renewal-hooks/post/http/cleanup.sh
        ```
        Copy-paste & save
        ```
        #!/bin/bash
        rm -f /var/www/letsencrypt/.well-known/acme-challenge/$CERTBOT_TOKEN
        ```
        Run
        ```
        $ sudo chmod +x /etc/letsencrypt/renewal-hooks/post/http/cleanup.sh
        ```

4. Run `certbot` with the following parameters to acquire a certificate
    
    ```
    $ sudo certbot certonly --apache --preferred-challenges=http \
        --manual-auth-hook /etc/letsencrypt/renewal-hooks/pre/http/authenticator.sh \
        --manual-cleanup-hook /etc/letsencrypt/renewal-hooks/post/http/cleanup.sh \
        -d $YOUR_DOMAIN_COM
    ```
    In case of success the output should contain the path to the newly created certificate files

    ```
    - Congratulations! Your certificate and chain have been saved at:
      /etc/letsencrypt/live/yourdomain.com/fullchain.pem
      Your key file has been saved at:
      /etc/letsencrypt/live/yourdomain.com/privkey.pem
    ```

5. Letsencrypt certificates are issued for a preiod of 90 days. In order to keep your certificate up to date you need to configure auto renewal
    
    - Test the renewal process
        ```
        $ sudo certbot renew --dry-run
        ```
    
    - If the dry run complted successfully create a cron job 
        ```
        $ echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew" | sudo tee -a /etc/crontab > /dev/null
        ```

6. Create a single unified cofiguration for enabling ssl on virtual hosts

    - Check if `options-ssl-apache.conf` was successfully created. This file is required for enabling ssl on virtual hosts and referenced by the virtual host configuration files
        ```
        $ sudo ls /etc/letsencrypt
        ```
        The output shoud contain the file name
    
    - Append the file with certificate references
        ```
        $ sudo nano /etc/letsencrypt/options-ssl-apache.conf
        ```
    - Copy-paste to the end of the file & save
        ```
        SSLCertificateFile /etc/letsencrypt/live/yourdomain.com/cert.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/yourdomain.com/privkey.pem
        SSLCertificateChainFile /etc/letsencrypt/live/yourdomain.com/chain.pem
        ```

    - Repalce `yourdomain.com` with the actual domain name in `letsencrypt.conf`
        ```
        $ sudo sed -i -e 's/yourdomain.com/'"$YOUR_DOMAIN_COM"'/g' /etc/letsencrypt/options-ssl-apache.conf
        ```

## Configure virtual hosts

1. Install `git`
    ```
    $ sudo yum install git
    ```
    Run `git --version` to confirm that `git` was successfully installed

2. Clone this repository into a local directory
    ```
    $ git clone --depth=1 https://github.com/shrideio/shoebox /tmp/shoebox
    ```
3. Rerplace `yourdomain.com` with the actual domain name in the virtual host files
    ```
    $ sudo find /tmp/shoebox/src/apache/conf.d/ -type f -exec sed -i -e 's/yourdomain.com/'"$YOUR_DOMAIN_COM"'/g' {} \;
    ```
    -  Copy the modified virtual host files into the working `conf.d` directory
    ```
    $ sudo cp /tmp/shoebox/src/apache/conf.d/*  /etc/httpd/conf.d
    ```
    - Restart Apache
    ```
    $ sudo systemctl restart httpd
    ```

## Install Docker

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

2.  Install required packages
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