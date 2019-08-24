## ProGet Setup
Check [ProGet Documentation](https://docs.inedo.com/docs/proget/overview) and [ProGet Linux Installation Guide](https://docs.inedo.com/docs/proget/installation/installation-guide/linux-docker) for more information.
> Run `echo $REPO_ROOT` to verify the environment variable is set before continuing the setup.

1. Stage ProGet (registry) and PostgreSQL (registry-db) containers
    > This setup uses PostgreSQL instead of Microsoft SQL Server what is different from the official ProGet guide. Check [ProGet Docker](https://hub.docker.com/r/inedo/proget/dockerfile) file for more detail.
    
    The following commands will navigate to the directory containing `registry_docker_compose.yml` and run the containers in the background.

    > The `.env` file in `/src/registry` contains environment variable values for the containers, review and modify if necessary.

    ```
    $ sudo cd $REPO_ROOT/src/registry
    $ sudo docker-compose up -d
    ```

    <a name="docker-logs"></a>Run `sudo docker ps` to verify that `registry` and `registry-db` containers are up and running. Proceed if no error is detected, otherwise check the container logs for troubleshooting using the following command `sudo docker logs [container name]`.

2. Configure ProGet

    - Navigate to registry.yourdomain.com and login as _Admin/Admin_ as described on the login screen. If an error reported check the container logs as mentioned above.

    - ProGet requires a license key to operate. Click on the cog icon ![Alt text](/resources/img/proget_cog.png?raw=true "ProGet administration console") in the top right corner to open the administration console. Browse to `Software Configuration -> License Key & Activation` and the click on the **[change]** link to open a prompt dialog. Enter the license key or navigate to MyInedo by clicking on the link shown in the info message. Create a new account or use existing to acquire a perpetually free license key. When the license key is entered click on *Save*. The update page will contain the **[activate]** link, click on it to activate the key. After closing the popup message confirming successful activation _Activation status_ is expected to show **The license key is activated**. If the desired result was not achieved and ProGet still remains inactive check the [license documentation](https://docs.inedo.com/docs/proget/administration/license).

    - Change the administrator's password. Hover onto the user icon ![Alt text](/resources/img/proget_user.png?raw=true "ProGet user") in the top right corner to open a context menu and then click on **Change Password** to open the change password dialog. After the password is changed the welcome message should disappear from the login screen.

    - Browse to the administration console, then navigate to `System Configuration -> Advanced Settings`. Set the value of `Web.BaseUrl` to the root url of the packages and containers registry (i.e. https://registry.yourdomain.com) and click on **Save Changes**. The service will restart causing a `502 Proxy Error` which is expected to disappear a manual page refresh.

3. Configure Security & Authentication

    - Browse to the administration console, then navigate to `Security & Authentication -> Users & Tasks`

    - Create two users, one for consuming feeds `FeedConsumer` and another for publishing packages `PackagePublisher`. Click on **Create User** to open the _Create User_ dialog.
        > Leave the _Group membership_ field blank.

    - Open the _Tasks_ tab after the users have been created.

    - Deprive `Anonymous` from `View & Download Packages` by removing the record from the task's row.

    - Assign `View & Download Packages` to `FeedConsumer`, and `View & Download Packages` and `Publish Packages` to `PackagePublisher`. Click on **Add Permission** to open the _Add Privilege_ dialog and create the aforementioned associations. The users and tasks grid is expected to look as follows:

        | Task                     | Scope     | Users & Groups                 |
        | :----------------------- |:--------- | :----------------------------- |
        | Publish Packages         | all feeds | PackagePublisher               |
        | View & Download Packages | all feeds | FeedConsumer, PackagePublisher |

4. Create API keys

    API keys are used for accessing ProGet feeds without exposing user credentials.

    - Browse to the administration console, then navigate to `Integrations & Extensibility -> API Keys`. 

    - Create exclusive API keys for the _FeedConsumer_ and _PackagePublisher_ users. Click on **Create API Key** to open the _Create API Key_ dialog. Fill in the _Impersonate user_ and _Description_ fields with matching user names (the API user is not shown in the API Keys table, that is why setting _Description_ is important). Click on **Save API Key** to save changes and proceed.

5. Create NuGet feed and Docker registry

    NuGet feed and Docker registry are needed for testing the continues integration setup.
    > This setup is focused on .NET Core projects. If it does not suit the case a different feed type can be created and used further. Check the Third-Party Packages & Feed Types section in the ProGet documentation for more detail.

    - Browse to `Feeds` and click on **Create New Feed** to open the _Create Feed_ dialog. Set _Feed name_ to `v2` (NuGet feeds already have `/nuget` endpoint root; v2 stands for the NuGet protocol version, v3 is not supported by the free licence). Choose _Third-party package format_ and select _NuGet_ from the dropdown. Click on **Create Feed** to save changes. 

    - ProGet supports feed connectors allowing to unify package feeds from different sources. Click on **add connector** to open the _Select Connector_ dialog, select `nuget.org` from the _Connector_ dropdown and click on *Save* to create a new feed. When _v2_ viewed in the feed viewer page (`Feed -> v2`) it is expected to display packages derived from _nuget.org_.

    - Browse to `Container` and click on **Create New Docker Registry** to open the _Create Docker Registry_ dialog. Enter the registry name, `docker.default` will be used further, and click on **Create Docker Registry** to save changes. Add a _hub.docker.com_ connector to the newly created registry similarly to what is described above.