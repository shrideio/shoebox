# Shoebox - minimalistic dev environment on CentOS 7

## Disable SELinux

1. Check SELinux status. It is recommended to disable SELinux for ease of using Docker, and installing and setting up other axilary services.

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
    $ systemctl enable httpd
    ```
3. Start the service and check its status
    ```
    $ systemctl start httpd
    $ systemctl status httpd
    ```
    You will see `active (running)` when the service is running
4. Open `80` and `443` ports
    ```
    $ sudo firewall-cmd --permanent --add-port=80/tcp
    $ sudo firewall-cmd --permanent --add-port=433/tcp
5. Browse `yourdomain.com` (assuming the the dns record has alredy been set up), you should see the apache default page

## Configure SSL

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
