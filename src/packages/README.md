# ProGet Setup

Check [ProGet Documentation](https://docs.inedo.com/docs/proget/overview) and [ProGet Linux Installation Guide](https://docs.inedo.com/docs/proget/installation/installation-guide/linux-docker) for more information.

### Preliminary checklist

- [x] `$REPO_ROOT` and `$SHOEBOX_ROOT` environment variables are set

    ```
    $ echo $REPO_ROOT
    $ echo $SHOEBOX_ROOT
    ```

- [x] Proget `secrets.ini` and `.env` files are generated

    > WARNING: DO NOT modify assigned values in the `.env` file. If necessary, modify the `secrets.ini` file and run `packages_containers_setup.sh` to override the current values.

    ```
    $ sudo cat $SHOEBOX_ROOT/proget/secrets.ini
    $ sudo cat $REPO_ROOT/src/packages/.env
    ```

- [x] packages._yourdomain.com_ subdomain is configured and serves https traffic

Proceed if all of the checks passes, otherwise, review the [landing page](/src/README.md#setup-outline) and continue when ready.


### Setup

1. Start ProGet (`packages`) and PostgreSQL (`packages-db`) containers.

    ```
    $ sudo cd $REPO_ROOT/src/packages
    $ sudo docker-compose up -d
    ```

    Run `$ sudo docker ps` to verify if the listed containers are up and running. Proceed if no error detected, otherwise run `$ sudo docker logs [container name]` to check the container logs for troubleshooting.


2. Configure ProGet

    Navigate to packages._yourdomain.com_ and login as _Admin/Admin_ as described on the login screen. If an error reported check the container logs as mentioned above.

    - Acquire a free license key for ProGet.

        - Open the administration console using the cog icon ![Alt text](/resources/img/proget_cog.png?raw=true "ProGet administration console") in the top right corner.

        - Browse to `Software Configuration -> License Key & Activation` and then click the _[change]_ link to open a prompt dialog. Enter the existing license key or navigate to the MyInedo website by clicking the link shown in the info message for acquiring a perpetually free license key.

        - Enter the license key and click [Save]. The updated page will contain the _activate_ link, click it for activation. The _Activation status_ is expected to show 'The license key is activated'.

        If the desired result was not achieved and ProGet still remains inactive check the [license documentation](https://docs.inedo.com/docs/proget/administration/license).

    - Change the administrator password.
    
        Hover with the mouse cursor onto the user icon ![Alt text](/resources/img/proget_user.png?raw=true "ProGet user") in the top right corner to open a context menu and then click _Change Password_ to open the change password dialog. After the password is changed the welcome message should disappear from the login screen.        

    - Change the packages registry url.

      Open the administration console ![Alt text](/resources/img/proget_cog.png?raw=true "ProGet administration console"), then navigate to `System Configuration -> Advanced Settings`. Set the `Web.BaseUrl` parameter to https://packages._yourdomain.com_ and click [Save Changes]. The ProGet service will restart automatically causing a `502 Proxy Error` response temporary.

    - Configure authentication and access policies.
        
        - Open the administration console using the cog icon ![Alt text](/resources/img/proget_cog.png?raw=true "ProGet administration console"), then navigate to `Security & Authentication -> Users & Tasks`.

        - Create two users, one for consuming feeds `FeedConsumer` and another for publishing packages `PackagePublisher`. Click [Create User] for opening the _Create User_ dialog, leave the _Group membership_ field blank.

        - Open the _Tasks_ tab. Firstly, deprive `Anonymous` of the `View & Download Packages` task by removing the entry. Then, in under the Add Permission: assign the `View & Download Packages` task to `FeedConsumer`, and the `View & Download Packages` and `Publish Packages` tasks to `PackagePublisher`.
        
        - Click [Add Permission] to open the _Add Privilege_ dialog and create the associations as follows:

            | Task                     | Scope     | Users & Groups                 |
            | :----------------------- |:--------- | :----------------------------- |
            | Publish Packages         | all feeds | PackagePublisher               |
            | View & Download Packages | all feeds | FeedConsumer                   |


3. Create API keys

    API keys are used for accessing ProGet feeds without exposing user credentials.

    - Open the administration console ![Alt text](/resources/img/proget_cog.png?raw=true "ProGet administration console"), then navigate to `Integrations & Extensibility -> API Keys`. 

    - Create API keys for the `FeedConsumer` and `PackagePublisher` users. Click [Create API Key] to open the _Create API Key_ dialog. Fill in the _Impersonate user_ and _Description_ fields with matching user names (the API user is not shown in the API Keys table, that is why setting _Description_ is important). Click [Save API Key] to save changes and proceed.

    - Create the `ci.packages` secret in Vault as described [here](/src/vault/README.md#create-a-secret) for storing credentials for pulling packages from by the CI service. The secret must contain the following key/value pairs:

        > WARNING: Do not forget to replace the _[FeedConsumer-API-key]_ with the FeedConsumer API key value.

      - `packages_username`/_FeedConsumer_
      - `packages_password`/[FeedConsumer-API-key]

4. Create NuGet feed

    > INFO: NuGet feed is required for testing the continuous integration setup.

    - Navigate to `Feeds` and click [Create New Feed] to open the _Create Feed_ dialog. Set _Feed name_ to `v2`, then choose _Third-party package format_ and select _NuGet_ from the dropdown. Click [Create Feed] to save changes. The created feed will be exposed through the following uri: packages._yourdomain.com_/nuget/v2/

        > INFO: There is no need for prefixing the feed name with `nuget` as the NuGet feeds uri root already contains that literal. `v2` stands for the NuGet protocol version, v3 support is not included into the free license.

    - ProGet supports feed connectors allowing to unify package feeds from different sources.
    For adding a NuGet connector for `nuget.org` click on the feed name `Feed -> v2`, and follow the breadcrumbs `[Manage Feed] -> add connector -> [Create Connector]` to open the _Create Connector_ dialog. Select `NuGet` as _Feed type_ leaving the rest of the inputs intact, then click [Save] to save changes and close the dialog. In the emerged _Select Connector_ dialog select _www.nuget.org_ as _Connector_ (should be preselected) and then click [Save] to save changes.

5. Push a sample NuGet package to the feed. The sample package is used for testing the integration between the ci and package services.

    - Instal .NET Core SDK

        ```
        $ sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
        $ sudo yum install dotnet-sdk-3.1
        ```

        Run `$ sudo dotnet --version` to verify that .NET Core SDK is successfully installed.

    - Push the sample package to the package management server

        > WARNING: Do not forget to replace the _[PackagePublisher-API-KEY]_ with the PackagePublisher API key.

        ```
        $ export PACKAGE_PATH=$REPO_ROOT/src/packages/package.sample/bin/Release/netstandard2.0/package.sample.1.0.0.nupkg
        $ export PUBLISHER_API_KEY=[PackagePublisher-API-KEY]
        $ sudo dotnet nuget push $PACKAGE_PATH --api-key $PUBLISHER_API_KEY --source https://packages.$YOUR_DOMAIN/nuget/v2/
        ```


> IMPORTANT: Despite of Proget advertising the Docker registry feature, it does not work correctly when the service is hosted in a Linux container due to the following issue [Docker Push to Proget Container Registry fails](https://forums.inedo.com/topic/2788/docker-push-to-proget-container-registry-fails).