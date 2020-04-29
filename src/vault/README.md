## Vault Setup

Check [Vault Documentation](https://www.vaultproject.io/docs/), and [Vault](https://hub.docker.com/_/vault) and [Consul](https://hub.docker.com/_/consul) Docker Hub pages for more information.

> INFO: Consul was chosen over the other open-source storage providers as it is officially supported by HashiCorp. Check available Vault [storage options](https://www.vaultproject.io/docs/configuration/storage/) for more detail.


### Preliminary checklist

- [x] `$REPO_ROOT` and `$SHOEBOX_ROOT` environment variables are set

    ```
    $ echo $REPO_ROOT
    $ echo $SHOEBOX_ROOT
    ```

- [x] Vault `.env` is generated

    ```
    $ sudo cat $REPO_ROOT/src/vault/.env
    ```

- [x] vault._yourdomain.com_ subdomain is configured and serves https traffic

Proceed if all of the checks pass, otherwise, review the [landing page](/src/README.md#setup-outline) and continue when ready.


### Setup

1. Start Vault (`vault`) and Consul (`vault-db`) containers.

    ```
    $ cd $REPO_ROOT/src/vault
    $ sudo docker-compose up -d
    ```

    Run `$ sudo docker ps | grep vault` to verify if the listed containers are up and running. Proceed if no error detected, otherwise run `$ sudo docker logs [container name]` to check the container logs for troubleshooting.

2. <a id="unseal-vault"></a>Unseal Vault

    - Navigate to vault._yourdomain.com_ to start the initial setup. It is recommended to have at least `5` _Key shares_ and `3` _Key threshold_ for the [key rotation](https://www.vaultproject.io/docs/internals/rotation.html). Set the values and click [Initialize]. 

    - After the root token and key shares are generated click the _Download keys_ link and download a json file containing the aforementioned tokens. Click [Continue to Unseal] to proceed with the setup.

      > IMPORTANT: Secure the file with tokens as the tokens will be used for accessing and managing the vault service.

    - Enter 3 out of 5 master key portions from the json file one by one to unseal the vault and click [Unseal] to proceed.

    - Choose _Token_ as the authentication method and enter the root token from the downloaded json file, then click [Sign in] to log in.

3. Enable KVv2 secrets engine

    > INFO: There is a variety of [secret engines](https://www.vaultproject.io/docs/secrets/index.html) supported by Vault designated for different use cases. KVv2 (key/value) secret engine is used for storing arbitrary secrets within the configured physical storage for Vault.

    - Click the _Secrets_ menu in the top left corner to navigate to the secrets management console, then click [Enable new engine +] to proceed.

    - Choose _KV_ as the secrets engine and click [Next] to proceed. 

        > INFO: Check the [KV engine documentation](https://www.vaultproject.io/docs/secrets/kv/kv-v2) for more information.

    - Set _Path_ to `secrets` and _Version_ to `2` (default KV engine version), then click [Enable Engine] to finish the secrets engine setup.

        > INFO: Ignore the following error if shown: _Upgrading from non-versioned to versioned data. This backend will be unavailable for a brief period and will resume service shortly_, and continue the setup.

4. <a name="create-a-secret"></a>Create a secret

    - Navigate to `Secrets -> secrets` to open the secret management console, then click [Create secret +].

    - Set _Path for this secret_ to `ci.build.sample` and create a single entry version data with the following key/value pair `hello_world`/`Hello world!`, then click [Save] to save changes.

        > IMPORTANT: The secret is used by the continuous integration server for a test build.

5. Configure machine identity access

    > INFO: Check [AppRole Pull Authentication](https://learn.hashicorp.com/vault/identity-access-management/iam-authentication) for more information.

    - Enable the AppRole authentication method.

        - Navigate to the `Access` menu and then click `Enable new method +`, then choose the _AppRole_ option from the list and click `Next` to continue.

        - Click the `Method Options` link to expand the options section and set  _Default Lease TTL_ and  _Max Lease TTL_ to `0` (zero), _Token Type_ to `service`. Click [Enable Method] to finish the authentication method setup.

    - Create a policy for authenticating and accessing secrets.
    
        Navigate to the `Policies`(top left) menu and click `Create ACL policy +`. Set _Name_ to `ciagent` and copy-paste the configuration bellow into the _Policy_ field.
    
        > IMPORTANT: `approle` is the alias for the _AppRole_ authentication method enabled earlier. If a different alias is chosen make sure to correct the `path` value for the login policy.
    
        ```
        # Login with AppRole
        path "auth/approle/login" {
            capabilities = [ "create", "read" ]
        }
        
        # Read all secrets
        path "secrets/data/*" {
            capabilities = [ "read" ]
        }
        ```

        Click [Create policy] to finish the policy setup.
    
    -  Create a role linked with the policy and generate a secret id for that role:
    
        Click the command shell icon (![Alt text](/resources/img/vault_shell.png?raw=true "Vault shell")) in the top right corner to open the UI shell and execute the following commands:

        - Create a new `ciagent` role and link it to the `ciagent` policy.

            ```
            > vault write auth/approle/role/ciagent policies="ciagent, default"
            ```

        - <a id="generate-secret-id"></a> Generate Secret ID for the `ciagent` role.

            ```
            > vault write -force auth/approle/role/ciagent/secret-id
            ```

            The output of the command should contain the `secret_id` value which is used as a password and must be saved for later use.

    - Reissue new Role Secret ID

        If the Secret ID value was not captured or lost the only way to restore it is to create a new one. 
        
        - Run the following command to list available secret-id keys.

            ```
            > vault list auth/approle/role/ciagent/secret-id
            ```

        - Use the Secret ID key from the output to replace the `[secret_id_accessor]` placeholder and run the following command to remove the current Secret ID.

            ```
            > vault write /auth/approle/role/ciagent/secret-id-accessor/destroy secret_id_accessor="[secret_id_accessor]"
            ```

        - Generate a new Secret ID as described in the [previous](#generate-secret-id) step.

    - <a name="issue-a-client-token"></a> Issue a client token

        - Read the `ciagent` role id, open the UI shell (![Alt text](/resources/img/vault_shell.png?raw=true "Vault shell")) and execute the following command.

            ```
            > vault read auth/approle/role/ciagent/role-id
            ```

            Capture the `role_id` value as it is used further for issuing an access token for accessing secrets via the Vault API.

        - Next, type `api` in the UI shell and press the `Enter` key to open _Vault API explorer_. Find `POST /auth/approle/login` and click on the section to expand it, then click [Try it out] to enable editing.
        
        - Fill in the `role_id` and `secret_id` request body parameters with matching values captured earlier. Then, click [Execute - send a request with your token to Vault] to send an authentication request and receive a response containing the client token. Capture the value of `client_token` from the response body as it needs to be verified before actual use.

    - <a name="read-secret"></a> Verifying if the access token is correct and the associated role can access the secret using the issue client token.

        - Log in to Vault using the client token and open the UI shell (![Alt text](/resources/img/vault_shell.png?raw=true "Vault shell")).

        - Execute the following command to read the content of `ci.build.sample` secret.

            ```
            > vault read secrets/data/ci.build.sample
            ```

            If an access error is displayed, check the correctness of role access policies configuration as described [here](#acl-policy).

    - Capture the access token value as an environment value by running the following command:

        ```
        export VAULT_TOKEN=[client_token]
        echo $VAULT_TOKEN
        ```

        The environment value will be used for configuring the integration between ci and vault servers.