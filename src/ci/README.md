## Drone CI Setup

Check [Drone documentation](https://docs.drone.io/), [Drone Vault plugin](https://readme.drone.io/extend/secrets/vault/), [Drone Docker plugin](http://plugins.drone.io/drone-plugins/drone-docker/) and [Awesome Drone](https://github.com/drone/awesome-drone) for more information.

> Run `echo $REPO_ROOT` and `echo $YOUR_DOMAIN` to verify if the environment variables are set before continuing.

1. Drone Vault plugin requires a Vault client token for fetching secrets from the Vault service (the token can be acquired as it is described [here](/src/vault/README.md#issue-a-client-token)).

      Run the following command to replace the placeholder.

      ```
      $ sudo find $REPO_ROOT/src/ci -type f -name '.env' -exec sed -i -e 's|@VAULT_TOKEN|'"$VAULT_TOKEN"'|g' {} \;
      ```

      Output the content of the `.env` file and visually verify if the placeholder was successfully replaced by the actual value.

      ```
      $ sudo cat $REPO_ROOT/src/ci/.env
      ```

2. Stage Drone CI (ci), Drone build agent (ci-agent), Drone Vault plugin (ci-secret) and PostgreSQL (ci-db) containers.

    The following commands will navigate to the directory containing `ci_docker_compose.yml` and run the containers in the background.

      ```
      $ sudo cd $REPO_ROOT/src/ci
      $ sudo docker-compose up -d
      ```

    > The `.env` file in the `/src/ci` directory contains environment variable values for the containers, review and modify if necessary.

    > Drone admin user and git user passwords are auto-generated and can be changed if necessary.

    Run `sudo docker ps` to verify if `ci`, `ci-secret` and `ci-db` containers are up and running. Proceed if no error is detected, otherwise run `sudo docker logs [container name]` to check the logs for troubleshooting.

3. Prepare a test build. The purpose of the test build is to very if secrets can be fetch from the vault service and if a container produced by the build pipeline can be pushed to the private Docker registry. The `/src/ci` directory contains a sample project `ci.build.sample` which is to run a test build.

    -  Create a secret entry for storing a build argument for the container. Follow the instruction for adding new secrets as described [here](/src/vault/README.md#create-a-secret). Set _Path for this secret_ to `ci.build.sample` and create the following key/value pair `hello_world`/`Hello world!`.

    -  Create a git user for the CI service to access the repository. Use the values of `DRONE_GIT_USERNAME` and `DRONE_GIT_PASSWORD` as user name and password accordingly. Create a repository named `ci.build.sample` under the drone git user.
      
        > For repositories not created under `DRONE_GIT_USERNAME` add that user as a collaborator to show all builds under a single entity, or use the personal git credentials for running affiliated builds.

    - Create a git user for the Drone admin user using the _username_ and _token_ values from the `DRONE_USER_CREATE` variable from the `.env` file mentioned above. The admin user is required when using Drone CLI for managing the service. Check the [Drone CLI documentation](https://docs.drone.io/cli/) for more information.

4. Active the repository for build. Navigate to `ci`.yourdomain.com and login using the git user create earlier. If the reposit is not shown click the **SYNC** button in the top right corner and wait. For activating the repository click the repository name or **ACTIVATE** which opens the _SETTINGS_ tab, then click **ACTIVATE REPOSITORY** for activation. Check *Trusted*  for _Project settings_ and click **SAVE** to save changes.

    > If the repository is not shown check if the git user (`DRONE_GIT_USERNAME`) is created and it can be logged in using the password (`DRONE_GIT_PASSWORD`). When logged in check if the repository is accessible for the user.

5. Add the sample project to the git repository and trigger a build.

      Replace the domain name placeholder with the actual value.
      > `.drone.yml` contains a build configuration for the sample project. Check the [Drone Pipeline](https://docs.drone.io/configure/pipeline/) documentation for more information.
      
      ```
      $ sudo sed -i 's|@YOUR_DOMAIN|'"$YOUR_DOMAIN"'|g' $REPO_ROOT/src/ci/ci.build.sample/.drone.yml
      $ cat $REPO_ROOT/src/ci/ci.build.sample/.drone.yml
      ```

      > Make sure that Vault is unsealed (check [here](/src/vault/README.md#unseal-vault)) before triggering a build, otherwise secrets will not be fetched successfully which result result in a failed build.

      > Do not forget to replace _yourdomain.com_ and _DRONE_GIT_USERNAME_ with the actual values.

      ```
      $ cd $REPO_ROOT/src/ci/ci.build.sample
      $ sudo git add .
      $ sudo git commit -m "Adding ci.build.sample"
      $ sudo git remote add origin https://git.yourdomain.com/DRONE_GIT_USERNAME/ci.build.sample
      $ sudo git remote -v
      $ sudo git push origin master
      ```

      `git push` will trigger a build. Open the repository details and check the latest build in the _ACTIVITY FEED_ tab. If build is successful (green (✓) check mark icon) it should create a _ci.build.sample_ Docker image with in the private registry (check `registryiu`.yourdomain.com). If the build is failed (red (X) icon) then click on the build record to open the build log and inspect the build log for trouble shooting.

6. Build failures troubleshooting

      The most fragile step of the build pipeline is `containerize`. It involves fetching secrets from Vault using the Drone secrets plugin and pushing the resulting image to the Docker registry. Drone CLI is used for checking secrets accessibility.
      
      - Install Drone CLI

        ```
        $ curl -L https://github.com/drone/drone-cli/releases/latest/download/
        $ drone_linux_amd64.tar.gz | tar zx
        $ sudo install -t /usr/local/bin drone 
        ```

      - For connecting to the Drone service the CLI uses the `DRONE_TOKEN` and `DRONE_SERVER` environment variables. For extracting the variable values login to the Drone web interface and click the user avatar (generated abstract pattern) in the top right corner and then navigate to _User settings_ link in the popup menu to open the _User Settings_ page (Alternatively that page can be accessed by navigating to ci.yourdomain.com/account). Copy-paste the content of _Example CLI Usage:_ section into the shell.

        ```
        $ export DRONE_SERVER=https://ci.yourdomain.com
        $ export DRONE_TOKEN=[ci-agent-token]
        $ drone info
        ```

        The output should contain the username and email.

    - For connecting to the secrets plugin the CLI uses the `DRONE_SECRET_ENDPOINT` and `DRONE_SECRET_SECRET` environment variables. Use the value of `DRONE_SECRET` from the `.env` file for setting `DRONE_SECRET_SECRET`.

      > If the port prefix (_ports_prefix.ini_) or the containers setup script (_setup_virtual_hosts.sh_) have not been not been modified the secret plugin port should be correct, otherwise run `sudo docker ps -a` and look up for the `ci-secret` container port binding.
        ```
        $ export DRONE_SECRET_ENDPOINT=http://localhost:10430
        $ export DRONE_SECRET_SECRET=[drone-secret-from-env]
        ```

    - For checking if secret are accessible run the following commands

      Check if Docker registry credentials are accessible
      ```
      $ drone plugins secret get secrets/data/ci.docker docker_username --repo ciagent/ci.build.sample
      ```

      Check if the build argument is accessible
      ```
      $ drone plugins secret get secrets/data/ci.build.sample hello_world --repo ciagent/ci.build.sample
      ```

      If correct secret values are displayed the cause of the issue is not related to the secrets plugin or Vault configuration, otherwise check `VAULT_TOKEN` by trying to login using its value and confirm that Access Login Policy is configured correctly as described [here](/src/vault/README.md#acl-policy).

    - If secrets fetching is not an issue check if the registry can be accessed by the provided username and password values ([here](/src/registry/README.md#docker-registry-username-and-password)) and the registry virtual host file has been amended as described [here](/README.md#modify-registry-vhost-config).

7. Check the build result by creating a container from the built image and pulling the endpoint which should display a backed-in message.
    
    > Do not forget to replace _yourdomain.com_ with the actual value.

    ```
    $ sudo docker run -d -p 9080:80 --name ci.build.sample registry.yourdomain.com/ci.test/ci.build.sample
    $ curl http://localhost:9080/api/hello
    ```

    If the `hello_world` secret value has not been modified the output should contain _Hello world!_ otherwise the modified value.