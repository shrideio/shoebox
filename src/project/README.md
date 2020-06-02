## Taiga Setup

Check [Taiga Documentation](https://taigaio.github.io/taiga-doc/dist/) and [Taiga Support page](https://tree.taiga.io/support/) for more information. Sample projects can be reviewed [here](https://tree.taiga.io/discover).

> INFO: The Taiga setup is based on a community maintained project [docker-taiga](https://github.com/docker-taiga/) maintained by [w1ck3dg0ph3r](https://github.com/w1ck3dg0ph3r). Docker images can be found in the [docker-taiga Docker Hub](https://hub.docker.com/u/dockertaiga) repository.


### Preliminary checklist

- [x] `$REPO_ROOT` and `$SHOEBOX_ROOT` environment variables are set

    ```
    $ echo $REPO_ROOT
    $ echo $SHOEBOX_ROOT
    ```

- [x] Taiga `secrets.ini` and `.env` files are generated

    ```
    $ sudo cat $SHOEBOX_ROOT/project-taiga/secrets.ini
    $ sudo cat $REPO_ROOT/src/project/.env
    ```

- [x] project._yourdomain.com_ subdomain is configured and serves https traffic.

- [x] [SMTP relay](/src/vault/README.md##smtp-relay) is configured


### Setup

 1. Start Taiga backend (`project-backend`), Taiga frontend (`project-frontend`), RabbitMQ server (`project-messaging`), Taiga events (`project-events`), Nginx reverse proxy (`project-proxy`), PostgreSQL (`project-db`) and Redis (`project-cache`) containers.

    ```
    $ cd $REPO_ROOT/src/project
    $ sudo docker-compose up -d
    ```

    Run `$ sudo docker ps | grep project` to verify if the containers listed above are up and running. Proceed if no error detected, otherwise run `$ sudo docker logs [container name]` to check the container logs for troubleshooting.

2. Configure the SMTP provider settings for sending invitation emails to Taiga users.

    Open the Taiga backend configuration file for edit.

    ```
    $ sudo nano $SHOEBOX_ROOT/project-taiga/backend/conf/config.py
    ```

    Uncomment the following settings by removing `#` from the beginning, and replace the placeholders with matching values.

    ```
    DEFAULT_FROM_EMAIL = [from-email]
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_USE_SSL = True
    EMAIL_HOST = [smtp-server-address]
    EMAIL_PORT = [smtp-server-port]
    EMAIL_HOST_USER = [smtp-user]
    EMAIL_HOST_PASSWORD = [smtp-password]
    ```

    Save changes, then restart the container using the following command:

    ```
    $ sudo docker restart project-backend
    ```

3. Change the default Taiga administrator password after the first login. Use the following user name and password: _admin_ and _123123_ for the initial login.

4. Create a new project and add a new user with a valid email address. If the SMTP configuration is correct, the user will receive an invitation email onto the provided email address.
