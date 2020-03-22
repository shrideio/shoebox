# Gogs Setup
Check [Gogs Documentation](https://gogs.io/docs) and  [Gogs on Docker Hub](https://hub.docker.com/r/gogs/gogs/) for more information.

### Preliminary checklist

- [x] `$REPO_ROOT` and `$SHOEBOX_ROOT` environment variables are set

    ```
    $ echo $REPO_ROOT
    $ echo $SHOEBOX_ROOT
    ```

- [x] Gogs `secrets.ini` and `.env` files are generated

    > WARNING: DO NOT modify assigned values in the `.env` file. If necessary modify, the `secrets.ini` file and run `git_containers_setup.sh` to override the current values.

    ```
    $ sudo cat $SHOEBOX_ROOT/gogs/secrets.ini
    $ sudo cat $REPO_ROOT/src/git/.env
    ```

- [x] git._yourdomain.com_ subdomain is configured and serves https traffic

- [x] SMTP relay is configured

Proceed if all of the checks passes, otherwise, check the [landing page](/src/README.md#setup-outline) and continue when ready.

### Setup

1. Start Gogs (git) and PostgreSQL (git-db) containers.
    
    ```
    $ sudo cd $REPO_ROOT/src/git
    $ sudo docker-compose up -d
    ```

    Run `$ sudo docker ps` for verifying if `git` and `git-db` containers are up and running. Proceed if no error is detected, otherwise run `$ sudo docker logs [container name]` to check the container logs for troubleshooting.

2. Configure Gogs

    - Navigate to git._yourdomain.com_ to open the Gogs installer page.

    - Set the configuration option as follows
      > IMPORTANT: Despite creating an admin user is optional it is recommended to create one as a failover in case the SMTP relay is unreachable.

      > INFO: Do not forget to replace `yourdomain.com` with the actual domain name and use real email addresses.

      | Database Settings |                                                                                           |
      | :---------------- | :---------------------------------------------------------------------------------------- |
      | Database Type     | **PostgreSQL**                                                                            |
      | Host              | `git-db:5432` (as defined in `git_docker_compose.yml`),                                   |
      | User              | `GOGS_POSTGRESQL_USER` from `secrets.ini`                                                 |
      | Password          | `GOGS_POSTGRESQL_PASSWORD` from `secrets.ini`                                             |
      | Database Name     | `GOGS_POSTGRESQL_DATABASE` from `secrets.ini`                                             |
      
      | Application General Settings |                              |
      | :--------------------------- | :--------------------------- |
      | Application URL              | https://git._yourdomain.com_ |

      | Optional Settings                        |                                      |
      | :--------------------------------------- | :----------------------------------- |
      | ***Email Service Settings***             |                                      |
      | SMTP Host                                | From SMTP relay settings             |
      | From                                     | i.e. git@_yourdomain.com_            |
      | Sender Email                             | From SMTP relay settings             |
      | Sender Password                          | From SMTP relay settings             |
      | Enable Register Confirmation             | [x] _Optional_                       |
      | Enable Mail Notification                 | [x]                                  |
      | ***Server and Other Services Settings*** |                                      |
      | Disable user self-registration           | [x]                                  |
      | Enable Require Sign In to View Pages     | [x]                                  |
      | ***Admin Account Settings***             |                                      |
      | Username                                 | i.e. gitadmin                        |
      | Admin Email                              | i.e. gitadmin@_yourdomain.com_       |

3. Click [Install Gogs]. If Gogs is installed successfully it will create the `app.ini` file at the path assigned to the `GOGS_DATA` parameter in `.env`. Check [Googs Configuration Cheat Sheet](https://gogs.io/docs/advanced/configuration_cheat_sheet) for post-installation configuration.

    > INFO: Do not forget to restart the `git` container after modifying `app.ini`, otherwise new configuration settings will not be applied.

4. Sign in with the admin user and follow the checklist:
    - [x] A new user can be created and receives an email notification upon registration
    - [x] A new repository can be created
    
    If the checks pass Gogs is successfully configured and ready for use. Otherwise, check the container logs or Gogs logs at `GOGS_DATA/log`.