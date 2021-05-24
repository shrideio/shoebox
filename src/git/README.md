# Gogs Setup
Check [Gogs Documentation](https://gogs.io/docs) and  [Gogs on Docker Hub](https://hub.docker.com/r/gogs/gogs/) for more information.

### Preliminary checklist

- [x] `$REPO_ROOT` and `$SHOEBOX_ROOT` environment variables are set

    ```
    $ echo $REPO_ROOT
    $ echo $SHOEBOX_ROOT
    ```

- [x] Gogs `secrets.ini` and `.env` files are generated

    ```
    $ sudo cat $SHOEBOX_ROOT/git-gogs/secrets.ini
    $ sudo cat $REPO_ROOT/src/git/.env
    ```

- [x] git._yourdomain.com_ subdomain is configured and serves https traffic

- [x] [SMTP relay](https://github.com/shrideio/shoebox#smtp-relay) is configured

Proceed if all of the checks pass, otherwise, check the [landing page](/src/README.md#setup-outline) and continue when ready.

### Setup

1. Start Gogs (git) and PostgreSQL (git-db) containers.

    ```
    $ cd $REPO_ROOT/src/git
    $ sudo docker-compose up -d
    ```

    Run `$ sudo docker ps | grep git` for verifying if `git` and `git-db` containers are up and running, proceed if no error is detected. Otherwise, run `$ sudo docker logs [container name]` to check the container logs for troubleshooting.

2. Configure Gogs

    - Navigate to git._yourdomain.com_ to open the Gogs installer page.

    - Set the configuration option as follows:

      > INFO: Do not forget to replace `yourdomain.com` with the actual domain name and use real email addresses.

      | Database Settings |                                                                                           |
      | :---------------- | :---------------------------------------------------------------------------------------- |
      | Database Type     | **PostgreSQL**                                                                            |
      | Host              | `git-db:5432` (as defined in `git-docker-compose.yml`),                                   |
      | User              | `GOGS_POSTGRESQL_USER` from `secrets.ini`                                                 |
      | Password          | `GOGS_POSTGRESQL_PASSWORD` from `secrets.ini`                                             |
      | Database Name     | `GOGS_POSTGRESQL_DATABASE` from `secrets.ini`                                             |
      
      | Application General Settings |                              |
      | :--------------------------- | :--------------------------- |
      | Application URL              | https://git._yourdomain.com_ |


      > IMPORTANT: Despite _Admin Account Settings_ being listed under the _Optional Settings_ section, it is highly recommended to create the administrator account on setup.

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

3. Click [Install Gogs], after the installation is completed verify the `app.ini` file is created at `$SHOEBOX_ROOT/git-gogs/data/gogs/conf`. Check [Googs Configuration Cheat Sheet](https://gogs.io/docs/advanced/configuration_cheat_sheet) for post-installation configuration.

    > INFO: Do not forget to restart the `git` container after modifying `app.ini`,otherwise, new configuration settings are not applied.