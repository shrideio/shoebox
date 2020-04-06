## Vault Setup

Check [Vault Documentation](https://www.vaultproject.io/docs/), and [Vault](https://hub.docker.com/_/vault) and [Consul](https://hub.docker.com/_/consul) Docker Hub pages for more information.

> INFO: Consul was chosen over the other open-source storage providers as it is officially supported by HashiCorp. Check available Vault [storage options](https://www.vaultproject.io/docs/configuration/storage/) for more detail.

### Preliminary checklist

- [x] `$REPO_ROOT` and `$SHOEBOX_ROOT` environment variables are set

    ```
    $ echo $REPO_ROOT
    $ echo $SHOEBOX_ROOT
    ```

- [x] Vault `secrets.ini` and `.env` files are generated

    > WARNING: DO NOT modify assigned values in the `.env` file. If necessary,modify the `secrets.ini` file and run `vault_containers_setup.sh` to override the current values.

    ```
    $ sudo cat $SHOEBOX_ROOT/vault/secrets.ini
    $ sudo cat $REPO_ROOT/src/vault/.env
    ```

- [x] vault._yourdomain.com_ subdomain is configured and serves https traffic

Proceed if all of the checks pass, otherwise, review the [landing page](/src/README.md#setup-outline) and continue when ready.


### Setup

1. Start Vault (`vault`) and Consul (`vault-db`) containers.

    > WARNING: DO NOT modify assigned values in the `.env` file. If necessary,modify the `secrets.ini` file and run `vault_containers_setup.sh` to override the current values.

    ```
    $ sudo cd $REPO_ROOT/src/vault
    $ sudo docker-compose up -d
    ```

    Run `$ sudo docker ps` to verify if the listed containers are up and running. Proceed if no error detected, otherwise run `$ sudo docker logs [container name]` to check the container logs for troubleshooting.

2. <a id="unseal-vault"></a>Unseal Vault

    - Navigate to vault._yourdomain.com_ to start the initial setup. It is recommended to have at least `5` _Key shares_ and `3` _Key threshold_ for the [key rotation](https://www.vaultproject.io/docs/internals/rotation.html). Set the values and click [Initialize]. 

    - After the root token and key shares are generated click the _Download keys_ link and download a json file containing the aforementioned tokens. Click [Continue to Unseal] to proceed the setup.

      > IMPORTANT: Secure the file with tokens as the tokens will be used for accessing and managing the vault service.

    - Enter 3 out of 5 master key portions from the json file one by one to unseal the vault and click [Unseal] to proceed.

    - Choose _Token_ as the authentication method and enter the root token from the downloaded json file then click [Sign in] to log in to the Vault web interface.

3. Enable KVv2 secrets engine

    > INFO: There is a variety of [secret engines](https://www.vaultproject.io/docs/secrets/index.html) supported by Vault designated for different use cases. KVv2 (key/value) secret engine is used for storing arbitrary secrets within the configured physical storage for Vault.

    - click the _Secrets_ menu in the top left corner to navigate to the secrets management console. Then click _Enable new engine_ to proceed.

    - Choose _KV_ as the secrets engine and click [Next] to proceed. Set _Path_ to `secrets` and _Version_ to `2` (default KV engine version). Click [Enable Engine] to finish the secret engine setup.

     Check the [KV engine documentation](https://www.vaultproject.io/docs/secrets/kv/kv-v2.html) for the engine options details and modify it if necessary.

4. <a name="create-a-secret"></a>Create a secret

    > The secret will be used by a continuous integration server for a test build.

    - Navigate to `Secrets -> secrets` to open the secret management console then click _Create secret_.

    - Set _Path for this secret_ to `ci.build.sample` and create a single entry version data with the following key/value pair `hello_world`/`Hello world!`, then click [Save] to save changes.

5. Configure machine identity access

    > INFO: Check [AppRole Pull Authentication](https://learn.hashicorp.com/vault/identity-access-management/iam-authentication) for more information.

    - Enable the AppRole authentication method:
        - Navigate to the `Access` menu > Enable new method, then choose the _AppRole_ option from the list and click [Next] to continue. 
    
        - Click the `Method Options` link to expand the options section and set _Default Lease TTL_ and  _Max Lease TTL_ to `30 days`, leave the _Path_ value (expected to be `approle`) intact. Click [Enable Method] to finish the authentication method setup.

    - <a id="acl-policy"></a>Create a policy for authenticating and accessing secrets
    
        Navigate to the `Policies` menu and click [Create ACL policy]. Set the _Name_ field to `ciagent` and copy-paste the configuration bellow into the _Policy_ field.
    
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
    
    -  Create a role linked with the policy and generate a secret id for that role:
    
        Click the Vault CLI shell icon (![Alt text](/resources/img/vault_shell.png?raw=true "Vault shell")) in the top right corner to open the command shell and execute the following commands:

        - Create a new `ciagent` role and link it to the `ciagent` policy.

            ```
            > vault write auth/approle/role/ciagent policies="ciagent, default"
            ```

        - Read Role ID. The Role ID value is used for issuing an access token for accessing secretes via the Vault API.

            ```
            > vault read auth/approle/role/ciagent/role-id
            ```

        - <a id="generate-secret-id"></a> Generate Secret ID for the `ciagent` role. The output of the command should contain the `secret_id` value which is used as a password and MUST BE capture for later use.

            ```
            > vault write -force auth/approle/role/ciagent/secret-id
            ```

    - Reissue new Secret ID

        If the Secret ID value was not captured or lost the only way to restore it is to create a new one. Run the following command to list available secret-id keys.

        ```
        > vault list auth/approle/role/ciagent/secret-id
        ```

        Use the secret-id key from the output to replace the `[secret_id_accessor]` placeholder and run the following command to remove the current Secret ID.

        ```
        > vault write /auth/approle/role/ciagent/secret-id-accessor/destroy secret_id_accessor="[secret_id_accessor]"
        ```

        Generate a new Secret ID as described in the [previous](#generate-secret-id) step.

    - <a name="issue-a-client-token"></a> Issue a client token

        - Type `api` in the UI shell  (![Alt text](/resources/img/vault_shell.png?raw=true "Vault shell")) and press the `Enter` key to open _Vault API explorer_. 
        
        -  Find `POST /auth/approle/login/` and click on the section to expand it, then click [Try it out] to enable editing.
        
        -  Fill in request body parameters with matching `role_id` and `secret_id` values, then click [Execute - send a request with your token to Vault] and follow the checklist to verify the setup correctness.

            - [x] `token_policies` contains the [configured polices](#acl-policy)
            - [x] `lease_duration` is set to _2592000_ (30 days in seconds)
            - [x] `renewable` is set to _true_
            - [x] `client_token` is not empty

            Proceed if the checks pass, otherwise consult with the Vault documentation.

        - Extract and save the `client_token` value, it will be used further for configuring the integration between the ci and vault servers.

            > WARNING: Replace `[client_token]` with the actual vault token value.

            ```
            export VAULT_TOKEN=[client_token]
            echo $VAULT_TOKEN
            ```