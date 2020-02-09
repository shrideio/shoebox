## TAIGA

The project managment tool is Taiga (Taiga.io) which supports SCRUM/KANBAN and allows flexibility in formatting your project planning.
The docker-compose file for taiga is a modified version of [@w1ck3dg0ph3r's](https://github.com/docker-taiga/taiga/commits?author=w1ck3dg0ph3r) docker-compose that can be found [here](https://github.com/docker-taiga/taiga).

Check [existing taiga projects](https://tree.taiga.io/discover) more information about how taiga looks like.

Note: The default login credentials (admin:123123) should be changed on first login for security reasons.

> Run `echo $REPO_ROOT` to verify if the environment variable is set before continuing.

Stage Taiga(project) container:

The following commands will navigate to the directory containing `project_docker_compose.yml` and run the containers in the background.

> The `.env` file in the `/src/git` directory contains environment variable values for the containers, review and modify if necessary.

```
$ sudo cd $REPO_ROOT/src/project
$ sudo docker-compose up -d
```

<a name="docker-logs"></a>Run `sudo docker ps` to verify that the `project-back`, `project-front`, `project-db`, `project-messaging`, `project-events`, `project-proxy` containers are up and running. Proceed if no errors are detected, otherwise run `sudo docker logs [container name]` to check the logs for troubleshooting.
