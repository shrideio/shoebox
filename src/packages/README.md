# ProGet Setup

Check [ProGet Documentation](https://docs.inedo.com/docs/proget/overview) and [ProGet Linux Installation Guide](https://docs.inedo.com/docs/proget/installation/installation-guide/linux-docker) for more information.

### Preliminary check list

- [x] `$REPO_ROOT` and `$SHOEBOX_ROOT` environment variables are set

    ```
    $ echo $REPO_ROOT
    $ echo $SHOEBOX_ROOT
    ```

- [x] Proget `secrets.ini` and `.env` files are generated

    > WARNING: DO NOT modify assigned values in the `.env` file. If necessary modify, the `secrets.ini` file and run `packages_containers_setup.sh` to override the current values.

    ```
    $ sudo cat $SHOEBOX_ROOT/proget/secrets.ini
    $ sudo cat $REPO_ROOT/src/packages/.env
    ```

- [x] packages._yourdomain.com_ subdomain is configured and serves https traffic

Proceed if all of the checks pass, otherwise check the [landing page](/src/README.md#setup-outline) and continue when ready.

### Setup

1. Start ProGet (registry) and PostgreSQL (registry-db) containers.

    ```
    $ sudo cd $REPO_ROOT/src/registry
    $ sudo docker-compose up -d
    ```

    Run `$ sudo docker ps` for verifying if if `registry` and `registry-db` containers are up and running. Proceed if no error is detected, otherwise run `$ sudo docker logs [container name]` to check the container logs for troubleshooting.


2. Configure ProGet

    Navigate to registry._yourdomain.com_ and login as _Admin/Admin_ as described on the login screen. If an error reported check the container logs as mentioned above.

    - Change the administrator's password.
    
        Hover onto the user icon ![Alt text](/resources/img/proget_user.png?raw=true "ProGet user") in the top right corner to open a context menu and then click _Change Password_ to open the change password dialog. After the password is changed the welcome message should disappear from the login screen.    

    - Acquire a free license key for ProGet:

        - Open the administration console. Click the cog icon ![Alt text](/resources/img/proget_cog.png?raw=true "ProGet administration console") in the top right corner.
        
        - Browse to `Software Configuration -> License Key & Activation` and then click the _[change]_ link to open a prompt dialog. Enter the exiting license key or navigate to MyInedo, by clicking the link shown in the info message, for creating a new one.

        - Enter the license key and click [Save]. The update page will contain the _activate_ link, click it for activation. The _Activation status_ is expected to show **The license key is activated**. 
        
        If the desired result was not achieved and ProGet still remains inactive check the [license documentation](https://docs.inedo.com/docs/proget/administration/license)

    - Change the packages registry url.
    
      Open the administration console using the cog icon ![Alt text](/resources/img/proget_cog.png?raw=true "ProGet administration console"), then navigate to `System Configuration -> Advanced Settings`. Set `Web.BaseUrl` to https://packages._yourdomain.com_ and click [Save Changes]. The ProGet service will restart automatically causing a `502 Proxy Error` response temporary.

    - Configure authentication and access policies.
        
        - Open the administration console using the cog icon ![Alt text](/resources/img/proget_cog.png?raw=true "ProGet administration console"), then navigate to `System Configuration -> Advanced Settings`, then navigate to `Security & Authentication -> Users & Tasks`.

        - Create two users, one for consuming feeds `FeedConsumer` and another for publishing packages `PackagePublisher`. Click [Create User] for opening the _Create User_ dialog, leave the _Group membership_ field blank.

        - Open the _Tasks_ tab. Firstly, deprive `Anonymous` from the `View & Download Packages` task by removing the entry. Then, assign the `View & Download Packages` task to `FeedConsumer`, and the `View & Download Packages` and `Publish Packages` tasks to `PackagePublisher`. 
        
        - Click [Add Permission] to open the _Add Privilege_ dialog and create the associations listed below.

            | Task                     | Scope     | Users & Groups                 |
            | :----------------------- |:--------- | :----------------------------- |
            | Publish Packages         | all feeds | PackagePublisher               |
            | View & Download Packages | all feeds | FeedConsumer                   |

4. Create API keys

    API keys are used for accessing ProGet feeds without exposing user credentials.

    - Browse to the administration console, then navigate to `Integrations & Extensibility -> API Keys`. 

    - Create exclusive API keys for the _FeedConsumer_ and _PackagePublisher_ users. click **Create API Key** to open the _Create API Key_ dialog. Fill in the _Impersonate user_ and _Description_ fields with matching user names (the API user is not shown in the API Keys table, that is why setting _Description_ is important). click **Save API Key** to save changes and proceed.

5. Create NuGet feed

    NuGet feed and Docker registry are needed for testing the continues integration setup.
    > This setup is focused on .NET Core projects. If it does not suit the case a different feed type can be created and used further. Check the Third-Party Packages & Feed Types section in the ProGet documentation for more detail.

    - Browse to `Feeds` and click **Create New Feed** to open the _Create Feed_ dialog. Set _Feed name_ to `v2` (NuGet feeds already have `/nuget` endpoint root; v2 stands for the NuGet protocol version, v3 is not supported by the free licence). Choose _Third-party package format_ and select _NuGet_ from the dropdown. click **Create Feed** to save changes.

    - ProGet supports feed connectors allowing to unify package feeds from different sources. click **add connector** to open the _Select Connector_ dialog, select `nuget.org` from the _Connector_ dropdown and click *Save* to create a new feed. When _v2_ viewed in the feed viewer page (`Feed -> v2`) it is expected to display packages derived from _nuget.org_.

    > Despite Proget offering the Docker registry feature, it does not function properly when hosted in a Linux container due to the following issue [Docker Push to Proget Container Registry fails](https://forums.inedo.com/topic/2788/docker-push-to-proget-container-registry-fails). That is why its use as a Docker registry temporarily retried and the official Docker registry is used instead.