## Docker Registry
Check [Docker Registry](https://docs.docker.com/registry/) and [Joxit Docker Registry UI](https://joxit.dev/docker-registry-ui/) documentation for more information.
> Run `echo $REPO_ROOT` to verify if the environment variable is set before continuing.

1. Stage Docker Registry (registry) and Docker Registry UI (registry-ui) containers.

    The following commands will navigate to the directory containing `ci_docker_compose.yml` and run the containers in the background.

      ```
      $ sudo cd $REPO_ROOT/src/registry
      $ sudo docker-compose up -d
      ```

    > The `.env` file in the `/src/registry` directory contains environment variable values for the containers, review and modify if necessary.
    
    > The registry user name and password can be found the in the `secrets.ini` file at `$DEV_ROOT/registry`.

    Run `sudo docker ps` to verify if `registry` and `registry-ui` containers are up and running. Proceed if no error is detected, otherwise run `sudo docker logs [container name]` to check the logs for troubleshooting.

2. Browse to **registry**.yourdomain.com and login using the user name password given in the `secrets.ini` file mentioned above. Proceeded if login succeeds, otherwise check the logs for troubleshooting.

> The following step requires Vault to be set up and running. If not, follow the [Vault setup instruction](/src/vault/README.md) and continue after.

3. Create a secret entry for storing the Docker registry username and password. Set _Path for this secret_ to `ci.docker` and create the following key/value pairs `docker_username`/`[docker-username-from-secrets-ini`] and `docker_password`/`[docker-password-from-secrets-ini]` replacing the placeholders with matching values from _secrets.ini_. Follow the instruction for adding new secrets as described [here](/src/vault/README.md#create-a-secret).