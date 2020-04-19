## Drone CI Setup

Check [Drone documentation](https://docs.drone.io/), [Drone Vault plugin](https://readme.drone.io/extend/secrets/vault/), [Drone Docker plugin](http://plugins.drone.io/drone-plugins/drone-docker/) and [Awesome Drone](https://github.com/drone/awesome-drone) for more information.

### Preliminary checklist

- [x] `$REPO_ROOT`, `$SHOEBOX_ROOT`, `$YOUR_DOMAIN` environment variables are set

    ```
    $ echo $REPO_ROOT
    $ echo $SHOEBOX_ROOT
    $ echo $YOUR_DOMAIN
    ```

- [x] Drone `secrets.ini` and `.env` files are generated

    > WARNING: DO NOT modify assigned values in the `.env` file. If necessary, modify the `secrets.ini` file and run `ci_containers_setup.sh` to override the current values.

    ```
    $ sudo cat $SHOEBOX_ROOT/ci-drone/secrets.ini
    $ sudo cat $REPO_ROOT/src/ci/.env
    ```

- [x] [Git](/src/git/README.md) service is up and running (git._yourdomain.com_)

- [x] [Docker](/src/registry/README.md) registry is up and running (registryui._yourdomain.com_)

- [x] [Vault](/src/vault/README.md) service is up and running and the vault is configured and [unsealed](/src/vault/README.md#unseal-vault) (vault._yourdomain.com_)

- [x] ci._yourdomain.com_ subdomain is configured and serves https traffic

Proceed if all of the checks passes, otherwise, review the [landing page](/src/README.md#setup-outline) and continue when ready.

### Setup

1. Drone Vault plugin requires a Vault client token for accessing secrets stored in the Vault service. Fetch the client token as described [here](/src/vault/README.md#issue-a-client-token) and then replace the placeholder in `.env` file running the following command.

    > WARNING: Do not forget to replace [vault-token] with the actual value

    ```
    $ export VAULT_TOKEN=[vault-token]
    $ sudo sed -i 's|@VAULT_TOKEN$|'"$VAULT_TOKEN"'|g' $REPO_ROOT/src/ci/.env
    $ cat $REPO_ROOT/src/ci/.env
    ```

2. Start Drone CI (`ci`), Drone build agent (`ci-agent`), Drone Vault plugin (`ci-secret-plugin`) and PostgreSQL (`ci-db`) containers.

      ```
      $ sudo cd $REPO_ROOT/src/ci
      $ sudo docker-compose up -d
      ```

    Run `$ sudo docker ps` to verify if the listed containers are up and running. Proceed if no error detected, otherwise run `$ sudo docker logs [container name]` to check the container logs for troubleshooting.

3. Prepare and run a test build. The purpose of the test build is to very if secrets can be fetched from Vault and the container produced by the build pipeline can be pushed to a private Docker registry.

    > INFO: The sample project can be found at `$REPO_ROOT/src/ci.build.sample`

    -  Using the secret `ci.build.sample` with the key value pair we already create in the vault setup, we are going to be pulling the value for `hello_world` for the ci sample project.

        - Secret path (_Path for this secret_ field): `ci.build.sample`
        - Secret key/value: `hello_world`/`Hello world!`

        The part describing the setup of the `ci.build.sample` secret can be found [here](/src/vault/README.md#create-a-secret).

    -  Create a git user for the CI service for enabling access to repositories. Use the values of `DRONE_GIT_USERNAME` and `DRONE_GIT_PASSWORD` from the `secrets.ini` file as username and password accordingly. After the user is created, make sure that the user has the setting: "This account has permissions to create Git Hooks" enabled. log in to the Git service and create a repository named `ci.build.sample`.

        > IMPORTANT: For repositories not created under `DRONE_GIT_USERNAME` adding that user as a admin collaborator should enable access for the CI service.


    - Activate the repository for build

      - Navigate to ci._yourdomain.com_ and log in using the CI git user create earlier. If the repository is not listed, click the [SYNC] button in the top right corner and wait.

        > WARNING: If the repository is still not shown after syncing use the CI git user credentials (`DRONE_GIT_USERNAME` and `DRONE_GIT_PASSWORD`) to login to the Git service and check if the repository is accessible.

      - For activating the repository click the repository name or [ACTIVATE], that should open the _SETTINGS_ tab, then click [ACTIVATE REPOSITORY] for activation. Check _Trusted_ in the _Project settings_ section and click [SAVE] to save changes.


    - Add the sample project to the repository and trigger a build.

        - Run the following commands to replace the `@YOUR_DOMAIN` placeholder in `.drone.yml` file with the actual value to set correct links to external services.

          > INFO: `.drone.yml` contains a build pipeline configuration for the sample project. Check the [Drone Pipeline documentation](https://docs.drone.io/configure/pipeline/) for more information.

          ```
          $ sudo sed -i 's|@YOUR_DOMAIN|'"$YOUR_DOMAIN"'|g' $REPO_ROOT/src/ci/ci.build.sample/.drone.yml
          $ cat $REPO_ROOT/src/ci/ci.build.sample/.drone.yml
          ```

      - Create a local git repository for the sample project and push its content to the Git service.

        > WARNING: Do not forget to replace [yourdomain.com] and [DRONE_GIT_USERNAME] placeholders with the actual values.

        ```
        $ cd $REPO_ROOT/src/ci/ci.build.sample
        $ sudo git init
        $ sudo git add .
        $ sudo git commit -m "Adding ci.build.sample"
        $ sudo git remote add origin https://git.[yourdomain.com]/[DRONE_GIT_USERNAME]/ci.build.sample
        $ sudo git remote -v
        $ sudo git push origin master
        ```

        > IMPORTANT: `git push` should trigger a build, otherwise, modify the `.trigger` file in the project directory and commit and push the change for triggering a build.

      - Navigate to ci._yourdomain.com_ and click the repository name, ci.build.sample, to open the details page and then open the _ACTIVITY FEED_ tab for checking the build status.

        - If the build is successful (green (✓) checkmark icon) it should create a _ci.build.sample_ Docker image in the Docker registry (check `registryiu`_.yourdomain.com_). Verify the image Create a container from the image and pulling the endpoint which should display the baked-in message from the `hello_world` secret.

          > WARNING: Do not forget to replace _[yourdomain.com]_ with the actual value.

          ```
          $ sudo docker run -d -p 9080:80 --name ci.build.sample registry.$YOUR_DOMAIN/ci.test/ci.build.sample
          $ curl http://localhost:9080/api/hello
          ```

          If the expected output is not shown consult with the troubleshooting section further for investigating the issue in detail.

        - If the build is failed (red (X) icon) open and inspect the build log for troubleshooting. The build-log can be accessed by clicking on the build record. If the failure cannot be inferred from the logs check the troubleshooting section further for investigating the issue in detail.


### Build failures troubleshooting

  - Set up Drone CLI

      Drone CLI is used for managing the service, running local builds and triggering rebuilding on the service if necessary. Check the [Drone CLI documentation](https://docs.drone.io/cli/) for more information.

    - Install Drone CLI

        ```
        $ curl -L https://github.com/drone/drone-cli/releases/latest/download/drone_linux_amd64.tar.gz | tar zx
        $ sudo install -t /usr/local/bin drone
        ```

    - Drone CLI requires the Drone admin user for running commands on the Drone service. The credential for the admin user can be extracted from the `DRONE_USER_CREATE` parameter from the `secrets.ini` file. Use the _username_ and _token_ parts to create a git user with matching username and password.

    - Drone CLI requires `DRONE_TOKEN` and `DRONE_SERVER`environment variables to before connecting to the Drone service. Conveniently, the commands to set those variables can be fetched from the Drone web interface. Use the admin user credentials to log in to the Drone web interface. In the landing page click on the user icon (auto-generated icon with an abstract pattern in the top right corner), and then click _User Settings_ in the emerged context menu. In the opened page find the _Example CLI Usage_ section and copy-paste its content into the shell and run the commands.

      > INFO: The commands should resemble the following piece of code

        ```
        $ export DRONE_SERVER=https://ci.[yourdomain.com]
        $ export DRONE_TOKEN=[ci-agent-token]
        ```

    - Check if the connection to the service can be established by running the following command.

      ```
      $ sudo drone info
      ```

      The output should contain the user information if connected or error text if failed.

- Troubleshooting

  The most fragile step of the build pipeline is `containerize` as it depends on external services - Vault and Docker Registry.

    - Check if the secret values can be fetched by the Drone Vault plugin

        Replace the placeholders with matching values from `$REPO_ROOT/src/ci/.env` an set the environment values as follows. 

        ```
        $ export DRONE_SECRET_ENDPOINT=http://localhost:[DRONE_VAULT_PLUGIN_PORT]
        $ export DRONE_SECRET_SECRET=[DRONE_SECRET]
        ```

        Check if the build argument is accessible.

        ```
        $ drone plugins secret get secrets/data/ci.build.sample hello_world --repo ciagent/ci.build.sample
        ```

        Check if Docker registry credentials are accessible.

        ```
        $ drone plugins secret get secrets/data/ci.registry registry_username --repo ciagent/ci.build.sample
        $ drone plugins secret get secrets/data/ci.registry registry_password --repo ciagent/ci.build.sample
        ```

        > WARNING: Be aware not to confuse the CLI to secret plugin communication or configurations errors with the real secret access issues reported as via _secret key not found_ or _secret not found_ error messages.

        If the secret values cannot check if the secrets are accessible by the generated token (`VAULT_TOKEN`) as described [here](/src/vault/README.md#read-secret).

    - Check Docker Registry configuration

      - Check if the registry can be accessed by the using the provided username and password values ([here](/src/registry/README.md#docker-registry-username-and-password))

      - Check if the registry virtual host file is amended as described [here](/README.md#modify-registry-vhost-config).