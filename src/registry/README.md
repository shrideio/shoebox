## Docker Registry
Check [Docker Registry](https://docs.docker.com/registry/) and [Joxit Docker Registry UI](https://joxit.dev/docker-registry-ui/) documentation for more information.
> Run `echo $REPO_ROOT` to verify if the environment variable is set before continuing.

1. Stage Docker Registry (registry) and Docker Registry UI (registry-ui) containers.

    The following commands will navigate to the directory containing `ci_docker_compose.yml` and run the containers in the background.

      ```
      $ sudo cd $REPO_ROOT/src/registry
      $ sudo docker-compose up -d
      ```

    Run `sudo docker ps` to verify if `registry` and `registry-ui` containers are up and running. Proceed if no error is detected, otherwise run `sudo docker logs [container name]` to check the logs for troubleshooting.

        The registry user name and password can be found the in the `secrets.ini` 

2. Browse to **registry**.yourdomain.com and login using the username and password given in the `secrets.ini` file at `$SHOEBOX_ROOT/registry`. Proceeded if login succeeds, otherwise check the logs for troubleshooting.

3. <a id="docker-registry-username-and-password"></a> Create a secret entry for storing the Docker registry username and password in Vault.

    > This step requires Vault to be set up and running, if not, follow the [Vault setup instruction](/src/vault/README.md) and continue after. 

    Create the `ci.docker` secret with the following key/value pairs `registry_username`/`@REGISTRY_USERNAME` and `registry_password`/`@REGISTRY_PASSWORD`. Use the `REGISTRY_USERNAME` and `REGISTRY_PASSWORD` values from the secrets file mentioned above to replace the placeholders. Follow the instruction for adding new secrets as described [here](/src/vault/README.md#create-a-secret).