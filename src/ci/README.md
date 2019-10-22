## Drone CI Setup

Check [Drone documentation](https://docs.drone.io/) and [Drone Vault plugin](https://readme.drone.io/extend/secrets/vault/) for more information.

> Run `echo $REPO_ROOT` to verify if the environment variable is set before continuing.

1. Drone Vault plugin requires a Vault client token for fetching secrets from the Vault service (the token can be acquired as it is described [here](/src/vault/README.md#issue-a-client-token)).

      Run the following command to replace the placeholder.

      ```
      $ sudo find $REPO_ROOT/src/ci -type f -name '.env' -exec sed -i -e 's|@VAULT_TOKEN|'"$VAULT_TOKEN"'|g' {} \;
      ```

      Output the content of the `.env` file and visually verify if the placeholder was successfully replaced by the actual value.

      ```
      $ sudo cat $REPO_ROOT/src/ci/.env
      ```

2. Stage Drone CI (ci), Drone build agent (ci-agent), Drone Vault plugin (ci-secret) and MySQL (ci-db) containers.

    The following commands will navigate to the directory containing `ci_docker_compose.yml` and run the containers in the background.

      ```
      $ sudo cd $REPO_ROOT/src/ci
      $ sudo docker-compose up -d
      ```

    > The `.env` file in the `/src/ci` directory contains environment variable values for the containers, review and modify if necessary.

    > Drone admin user and git user passwords are auto-generated and can be changed if necessary.

    Run `sudo docker ps` to verify if `ci`, `ci-secret` and `ci-db` containers are up and running. Proceed if no error is detected, otherwise run `sudo docker logs [container name]` to check the logs for troubleshooting.

3. Prepare to run a test build. The purpose of the test build is to very if secrets can be fetch from the vault service and if a container produced by the build pipeline can be pushed to the private Docker registry.

    -  Create a secret entry for storing a pass in value for a built container. Set _Path for this secret_ to `ci.build.sample` and create the following key/value pair `hello_world`/`Hello world!` Follow the instruction for adding new secrets as described [here](/src/vault/README.md#create-a-secret).

    -  Create a git user for the CI service to access the repository. Use the values of `DRONE_GIT_USERNAME` and `DRONE_GIT_PASSWORD` as use name and password accordingly for creating the git user.

    - Add the sample project to the git repository.

      > Do not forget to replace _yourdomain.com_ and _DRONE_GIT_USERNAME_ with actual values. 

      ```
      $ cd $REPO_ROOT/src/ci/ci.build.sample
      $ sudo git add .
      $ sudo git commit -m "Adding ci.build.sample"
      $ sudo git remote add origin https://git.yourdomain.com/DRONE_GIT_USERNAME/ci.build.sample
      $ sudo git remote -v
      $ git push origin master
      ``` 

 
