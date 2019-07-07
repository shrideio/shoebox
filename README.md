# Shoebox - minimalistic dev environment for runnig on a cheap vps

## Disable SELinux on CentOS 7

1. Check SELinux status. If SELinux is enabled it is recommended to disable it for the ease of use Docker

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

2.  Install required packages.
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

## Prepare to bootstrap
1. Install git
    ```
    $ sudo yum install git
    ```
3. Create a work directory
    ```
    mkdir /var/dev
    ```
2. Shallow clone this repository
    ```
    $ git clone --depth 1 https://github.com/shrideio/shoebox.git /var/dev/shoebox
    ```
