## Drone CI Setup
Check [Drone documentation](https://docs.drone.io/) and [Drone Vault plugin](https://readme.drone.io/extend/secrets/vault/) for more information.
> Run `echo $REPO_ROOT` to verify if the environment variable is set before continuing.

1. Stage Drone CI (ci), Drone build agent (ci-agent), Drone Vault plugin (ci-secret) and MySQL (ci-db) containers.

    The following commands will navigate to the directory containing `ci_docker_compose.yml` and run the containers in the background.

      ```
      $ sudo cd $REPO_ROOT/src/ci
      $ sudo docker-compose up -d
      ```

    > The `.env` file in the `/src/ci` directory contains environment variable values for the containers, review and modify if necessary.
    
    > Drone admin user and git user passwords are auto-generated and may be changed if necessary.

    Run `sudo docker ps` to verify if `ci`, `ci-secret` and `ci-db` containers are up and running. Proceed if no error is detected, otherwise run `sudo docker logs [container name]` to check the logs for troubleshooting.
