# ProGet Setup

Check [ProGet Documentation](https://docs.inedo.com/docs/proget/overview) and [ProGet Linux Installation Guide](https://docs.inedo.com/docs/proget/installation/installation-guide/linux-docker) for more information.

### Preliminary checklist

- [x] `$REPO_ROOT` and `$SHOEBOX_ROOT` environment variables are set.

    ```
    $ echo $REPO_ROOT
    $ echo $SHOEBOX_ROOT
    ```

- [x] Proget `secrets.ini` and `.env` files are generated.

    ```
    $ sudo cat $SHOEBOX_ROOT/packages-proget/secrets.ini
    $ sudo cat $REPO_ROOT/src/packages/.env
    ```

- [x] [Vault](/src/vault/README.md) service is up and running, and the vault is configured and [unsealed](/src/vault/README.md#unseal-vault) (vault._yourdomain.com_)

- [x] packages._yourdomain.com_ subdomain is configured and serves https traffic.

Proceed if all of the checks pass, otherwise, review the [landing page](/src/README.md#setup-outline) and continue when ready.


### Setup

1. Start ProGet (`packages`) and PostgreSQL (`packages-db`) containers.

    ```
    $ cd $REPO_ROOT/src/packages
    $ sudo docker-compose up -d
    ```

    Run `$ sudo docker ps | grep packages` to verify if the containers listed above are up and running. Proceed if no error detected, otherwise run `$ sudo docker logs [container name]` to check the container logs for troubleshooting.


2. Configure ProGet

    Navigate to packages._yourdomain.com_ and login as _Admin/Admin_ as described on the login screen. If an error reported check the container logs as mentioned above.

    - Activate ProGet with a free licence key

        - Open the administration console using the cog icon ![Alt text](/resources/img/proget_cog.png?raw=true "ProGet administration console") in the top right corner.

        - Browse to `System -> License Key & Activation` and then click the _[change]_ link to open a prompt dialog. Enter the existing license key or navigate to the MyInedo website by clicking the link shown in the info message for acquiring a perpetually free license key.

        - Enter the license key and click [Save], the updated page will contain the _[activate]_ link, click it for activation. If auto-activation cannot be completed, the _Manual Activation Required_ dialog is displayed. Follow the instruction shown in the dialog to complete the activation process. If Proget is activated successfully, _Activation status_ will show 'The license key is activated' message.

        If the desired result was not achieved and ProGet remains inactive, check the [license documentation](https://docs.inedo.com/docs/proget/administration/license).

    - Change the administrator password
    
        Hover with the mouse cursor onto the user icon ![Alt text](/resources/img/proget_user.png?raw=true "ProGet user") in the top right corner to open a context menu and then click _Change Password_ to open the change password dialog. After the password is changed, the welcome message should disappear from the login screen.

    - Change the packages registry url.

      Open the administration console ![Alt text](/resources/img/proget_cog.png?raw=true "ProGet administration console"), then navigate to `System -> Advanced Settings`. Set the `Web.BaseUrl` parameter to https://packages._yourdomain.com_ and click [Save Changes], the ProGet service will restart automatically.

    - Configure authentication and access policies.
        
        - Open the administration console using the cog icon ![Alt text](/resources/img/proget_cog.png?raw=true "ProGet administration console"), then navigate to `Security & Authentication -> Users & Tasks`.

        - Create two users, one for consuming feeds `FeedConsumer` and another for publishing packages `PackagePublisher`. Click [Create User] for opening the _Create User_ dialog, leave the _Group membership_ field blank.

        - Open the _Tasks_ tab. Firstly, deprive `Anonymous` of the `View & Download Packages` task by removing the entry. Then, using the [Add Permission] button assign `View & Download Packages` task to `FeedConsumer`, and `Publish Packages` task to `PackagePublisher`.
        
            The task to user associations should look as follows:

            | Task                     | Scope     | Users & Groups                 |
            | :----------------------- |:--------- | :----------------------------- |
            | Publish Packages         | all feeds | PackagePublisher               |
            | View & Download Packages | all feeds | FeedConsumer                   |


3. Create API key for PackagePublisher

    API keys are used for accessing ProGet feeds without exposing user credentials.

    - Open the administration console ![Alt text](/resources/img/proget_cog.png?raw=true "ProGet administration console"), then navigate to `Security & Authentication -> API Keys & Access Logs`. 

    - Create an API key for `PackagePublisher` user.
    
        Click [Create API Key] to open the _Create API Key_ dialog. Fill in the _Feed API user_ with matching user names, and enable access to _Feed API_ by checking _Grant access to Feed API_ checkbox. Click [Save API Key] to save changes and proceed.

4. Create secret for FeedConsumer

    - Create the `ci.packages` secret in Vault as described [here](/src/vault/README.md#create-a-secret) for storing credentials for pulling packages from by the CI service. The secret must contain the following key/value pairs:

        > WARNING: Do not forget to replace the _[FeedConsumer-password]_ with the FeedConsumer password value.

      - `packages_username`/_FeedConsumer_
      - `packages_password`/[FeedConsumer-password]

5. Create NuGet feed

    > INFO: NuGet feed is required for testing the continuous integration setup.

    - Navigate to `Feeds` and click [Create New Feed] to open the _Create Feed_ dialog. Set _Feed name_ to `v2`, then choose _Third-party package format_ and select _NuGet_ from the dropdown. Click [Create Feed] to save changes. The created feed is exposed through the following uri: packages._yourdomain.com_/nuget/v2/

        > INFO: There is no need for prefixing the feed name with _nuget_ as the NuGet feeds uri root already contains that literal. _v2_ stands for the NuGet protocol version.

    - ProGet supports feed connectors allowing to unify package feeds from different sources. For adding a NuGet connector for `nuget.org` click on the feed name `Feed -> v2`, and follow the path `[Manage Feed] -> add connector -> [Create Connector]` to open the _Create Connector_ dialog. Select `NuGet` as _Feed type_, leaving the rest of the inputs intact, then click [Save] to save changes and close the dialog. In the emerged _Select Connector_ dialog select _www.nuget.org_ as _Connector_ (should be preselected), then click [Save] to save changes.

5. Push a sample NuGet package to the feed. The sample package is used for testing the integration between the CI and package services.

    - Install .NET Core SDK

        ```
        $ sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
        $ sudo yum install -y dotnet-sdk-3.1
        ```

        Run `$ sudo dotnet --version` to verify that .NET Core SDK is successfully installed.

    - Push the sample package to the package management server

        > WARNING: Do not forget to replace the _[PackagePublisher-API-KEY]_ with the PackagePublisher API key.

        ```
        $ export PACKAGE_PATH=$REPO_ROOT/src/packages/package.sample/bin/Release/package.sample.1.0.0.nupkg
        $ export PUBLISHER_API_KEY=[PackagePublisher-API-KEY]
        $ sudo dotnet nuget push $PACKAGE_PATH --api-key $PUBLISHER_API_KEY --source https://packages.$YOUR_DOMAIN/nuget/v2/
        ```

        Navigate to the feed `Feed -> v2` and verify if the package is successfully uploaded.

### Known issues

- The ProGet container may occasionally stall when pulling packages causing build failures due to unreachable packages. The more or less stable version is `5.1.23` with `Postgres 11`, both pinned in the Docker Compose script. Be advised to restart the `packages` container if it becomes unresponsive, as there is no known solution for that issue currently. Unfortunately, reviewing the container logs and searching the Internet for answers did not yield any success in finding the root cause of the issue. The most reasonable answer could be found [here](https://forums.inedo.com/topic/2670/service-unavailable-timeout), however the suggested solution did not make much difference.

- Postgres support for ProGet Docker is deprecated, and will no longer be supported by v6.0 (due out in 2020), check [here](https://inedo.com/support/kb/1166/upgrade-notes-for-proget-5-2#postgres) for more information. The alternative is to use Microsoft SQL Server Express edition hosted in a [linux container](https://hub.docker.com/_/microsoft-mssql-server). Unfortunately, Microsoft SQL Server is quite demanding to hardware, especially RAM (at least 2G), and will affect the minimal system requirements of Shoebox. The current decision is to continue with the ProGet version supporting Postgres. However, migration to Microsoft SQL Server in the future is not entirely excluded.

- Despite ProGet advertising the Docker registry feature, it does not work correctly when the service is hosted in a Linux container due to the following issue [Docker Push to Proget Container Registry fails](https://forums.inedo.com/topic/2788/docker-push-to-proget-container-registry-fails).