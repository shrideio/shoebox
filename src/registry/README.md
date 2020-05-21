## Docker Registry
Check [Docker Registry](https://docs.docker.com/registry/) and [Joxit Docker Registry UI](https://joxit.dev/docker-registry-ui/) documentation for more information.


### Preliminary checklist

- [x] `$REPO_ROOT` and `$SHOEBOX_ROOT` environment variables are set

    ```
    $ echo $REPO_ROOT
    $ echo $SHOEBOX_ROOT
    ```

- [x] Docker registry `secrets.ini` and `.env` files are generated

    ```
    $ sudo cat $SHOEBOX_ROOT/registry-docker/secrets.ini
    $ sudo cat $REPO_ROOT/src/registry/.env
    ```

- [x] [Vault](/src/vault/README.md) service is up and running, and the vault is configured and [unsealed](/src/vault/README.md#unseal-vault) (vault._yourdomain.com_)

- [x] registryui._yourdomain.com_ and registry._yourdomain.com_ subdomains are configured and serve https traffic


Proceed if all of the checks pass, otherwise, review the [landing page](/src/README.md#setup-outline) and continue when ready.


### Setup

  1. Start Docker Registry (`registry`) and Docker Registry UI (`registry-ui`) containers.

      ```
      $ cd $REPO_ROOT/src/registry
      $ sudo docker-compose up -d
      ```

      Run `$ sudo docker ps | grep registry` to verify if the containers listed above are up and running. Proceed if no error detected, otherwise run `$ sudo docker logs [container name]` to check the container logs for troubleshooting.

  2. Verify if the Docker registry user can log in. Browse to **registryui**._yourdomain.com_ and use the values of `REGISTRY_USERNAME` and `REGISTRY_PASSWORD` parameters from the Docker registry `secrets.ini` file.

  3. <a id="docker-registry-username-and-password"></a> Create the `ci.registry` secret in Vault as described [here](/src/vault/README.md#create-a-secret) for storing Docker registry username and password. The secret must contain the following key/value pairs.

      - `registry_username`/[REGISTRY_USERNAME]
      - `registry_password`/[REGISTRY_PASSWORD]

     Use the values of parameters matching the placeholder names from the Docker registry `secrets.ini` file.