## Taiga Setup

Check [Taiga Documentation](https://taigaio.github.io/taiga-doc/dist/), [Taiga Support page](https://tree.taiga.io/support/) for more information.

Check [existing taiga projects](https://tree.taiga.io/discover) to get acquainted with sample projects.

⚠️ATTENTION: The default login credentials are **admin**:**123123**. It should be changed on first login for security reasons.⚠️

> Run `echo $REPO_ROOT` to verify if the environment variable is set before continuing.

Stage Taiga (project-*) containers.

The following commands will navigate to the directory containing `project_docker_compose.yml` and run the containers in the background.

> The `.env` file in the `/src/project` directory contains environment variable values for the containers, review and modify if necessary.

```
$ sudo cd $REPO_ROOT/src/project
$ sudo docker-compose up -d
```

Run `sudo docker ps` to verify that the following containers are up and running.
  - `project-back`
  - `project-front`
  - `project-db`
  - `project-messaging`
  - `project-events`
  - `project-proxy`

Proceed if no errors are detected, otherwise run `sudo docker logs [container name]` to check the logs for troubleshooting.

> The docker-compose file for taiga is a modified version of [@w1ck3dg0ph3r's](https://github.com/docker-taiga/taiga/commits?author=w1ck3dg0ph3r) docker-compose that can be found [here](https://github.com/docker-taiga/taiga)
