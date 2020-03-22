## Docker Registry
Check [Docker Registry](https://docs.docker.com/registry/) and [Joxit Docker Registry UI](https://joxit.dev/docker-registry-ui/) documentation for more information.


### Preliminary checklist

- [x] `$REPO_ROOT` and `$SHOEBOX_ROOT` environment variables are set

    ```
    $ echo $REPO_ROOT
    $ echo $SHOEBOX_ROOT
    ```

- [x] Docker registry `secrets.ini` and `.env` files are generated

    > WARNING: DO NOT modify assigned values in the `.env` file. If necessary modify, the `secrets.ini` file and run `registry_containers_setup.sh` to override the current values.

    ```
    $ sudo cat $SHOEBOX_ROOT/registry/secrets.ini
    $ sudo cat $REPO_ROOT/src/registry/.env
    ```

- [x] registryui._yourdomain.com_ and registry._yourdomain.com_ subdomains are configured and serve https traffic

- [x] [Vault](/src/vault/README.md) service is up and running and the vault is configured and [unsealed](/src/vault/README.md#unseal-vault) (vault._yourdomain.com_)

Proceed if all of the checks pass, otherwise, review the [landing page](/src/README.md#setup-outline) and continue when ready.


### Setup

  1. Start Docker Registry (registry) and Docker Registry UI (registry-ui) containers.

      ```
      $ sudo cd $REPO_ROOT/src/registry
      $ sudo docker-compose up -d
      ```

      Run `$ sudo docker ps` to verify if `registry` and `registry-ui` containers are up and running. Proceed if no error is detected, otherwise run `$ sudo docker logs [container name]` to check the container logs for troubleshooting.

  2. Verify that  Docker registry user can log in. Browse to **registryui**._yourdomain.com_ and use the values of `REGISTRY_USERNAME` and `REGISTRY_PASSWORD` parameters from the `secrets.ini` file as username and password accordingly to log in. Proceeded if the login succeeded, otherwise, check the container logs for troubleshooting.

3. <a id="docker-registry-username-and-password"></a> Create a secret in Vault for storing the Docker registry username and password. Following the as described [here](/src/vault/README.md#create-a-secret) create a new secret under the `ci.docker` path with the following key/value pairs (use the values fetched earlier to replace matching  placeholders):

    > INFO: The `ci.docker` secret is used by the CI service for authenticating when creating a Docker image in the registry

      - `registry_username`/`[REGISTRY_USERNAME]`
      - `registry_password`/`[REGISTRY_PASSWORD]`