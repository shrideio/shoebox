## Taiga Setup

Check [Taiga Documentation](https://taigaio.github.io/taiga-doc/dist/) and [Taiga Support page](https://tree.taiga.io/support/) for more information. Sample project can be discovered [here](https://tree.taiga.io/discover).

> INFO: The Taiga setup is based on the community maintained project [docker-taiga](https://github.com/docker-taiga/) provided by [w1ck3dg0ph3r](https://github.com/w1ck3dg0ph3r). Docker images can be found in the [docker-taiga Docker Hub](https://hub.docker.com/u/dockertaiga) repository.


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


### Setup

 1. Start Taiga backend (`project-backend`), Taiga frontend (`project-frontend`), RabbitMQ server (`project-messaging`), Taiga events (`project-events`), Nginx reverse proxy (`project-proxy`), PostgreSQL (`project-db`) and Redis (`project-cache`) containers.

    ```
    $ cd $REPO_ROOT/src/project
    $ sudo docker-compose up -d
    ```

    Run `$ sudo docker ps | grep project` to verify if the containers listed above are up and running. Proceed if no error detected, otherwise run `$ sudo docker logs [container name]` to check the container logs for troubleshooting.

2. Updated SMTP settings with the information from the SMTP provider in order to be able to add new users to projects:

    ```
    $ nano $SHOEBOX_ROOT/project-taiga/backend/conf/config.py
    ```
    ```
    Remove the '#' and set the following values(Replace the values inside square brackets with your values):
    DEFAULT_FROM_EMAIL = [FROM_EMAIL]
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_USE_SSL = True
    EMAIL_HOST = [SMTP_ADDRESS]
    EMAIL_PORT = [SMTP_PORT]
    EMAIL_HOST_USER = [SMTP_USER]
    EMAIL_HOST_PASSWORD = [SMTP_PASSWORD]
    ```

    After setting up these values, restart the container using the following command:
   
    ```
    $ sudo docker restart project-backend
    ```

3. Change the default Taiga administrator password after the first login. Use the following user name and password: _admin_ and _123123_ for the initial login.

4. Try setting a new project and adding a new user with a valid email in order to verify that emails are being sent via the SMTP server.
