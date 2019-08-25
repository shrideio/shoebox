## Vault Setup
Check [Vault Documentation](https://www.vaultproject.io/docs/) and [Vault](https://hub.docker.com/_/vault) and [Consul](https://hub.docker.com/_/consul) Docker Hub pages for more information.
> Run `echo $REPO_ROOT` to verify if the environment variable is set before continuing.

1. Stage Vault (vault) and Consul (vault-db) containers.

    > Consul was chosen over other open source storage providers as it is officially supported by HashiCorp. Check available Vault [storage options](https://www.vaultproject.io/docs/configuration/storage/) for more detail.

    The following commands will navigate to the directory containing registry_docker_compose.yml and run the containers in the background.

    > The `.env` file in the `/src/vault` contains environment variable values for the containers, review and modify if necessary.

    ```
    $ sudo cd $REPO_ROOT/src/vault
    $ sudo docker-compose up -d
    ```

    Run `sudo docker ps` to verify if `vault` and `vault-db` containers are up and running. Proceed if no error is detected, otherwise check the container logs for troubleshooting using the following command `sudo docker logs [container name]`.


2. Unseal Vault

    - Navigate to vault._yourdomain.com_ to start initial setup. It is recommended to have at least **5** _Key shares_ and **3** _Key threshold_ for the [key rotation](https://www.vaultproject.io/docs/internals/rotation.html). Set the values and click on **Initialize**. 
    
    - After the root token and key shares are generated click on the _Download keys_ link and download a json file containing the aforementioned tokes. Click on **Continue to Unseal** to proceed the setup.
      > **Important**: Secure the file with tokens or the token as it will be used for accessing and managing the vault content.

    - Enter 3 out of 5 master key portions from the json file one by one to unseal the vault and click on **Unseal** to proceed.

    - Choose _Token_ as the authentication method and enter the root token from the json file. Click on **Sign in** to proceed.

3. Enable new secrets engine

    > There is a variety of [secret engines](https://www.vaultproject.io/docs/secrets/index.html) supported by Vault designated for different cases. **KV v2** (key/value) secret engine is  used to store arbitrary secrets within the configured physical storage for Vault.

    - Click on the _Secrets_ menu in the top right corner to navigate to the secrets management console. Then click on _Enable new engine_ to proceed.

    - Choose **KV** as a secrets engine and click on **Next** to proceed. Set _Path_ to `test` and _Version_ to `2` (default KV engine version). Check the [KV engine documentation](https://www.vaultproject.io/docs/secrets/kv/kv-v2.html) for the engine options details and modify if necessary. Click on **Enable Engine** to finish the setup.


4. Create secret

    > The secret will be used by the build server for a test build. 

    - Navigate to `Secrets -> test` to open the secret management console the click on _Create secret_.

    - Set _Path for this secret_ to `ci.test` and crete a single entry version data with the following key/value pair `HELLO_WORLD`/`Hello world!`. Click on **Save** to save changes. 