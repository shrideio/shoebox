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


2. <a id="unseal-vault"></a>Unseal Vault

    - Navigate to vault._yourdomain.com_ to start initial setup. It is recommended to have at least **5** _Key shares_ and **3** _Key threshold_ for the [key rotation](https://www.vaultproject.io/docs/internals/rotation.html). Set the values and click **Initialize**. 

    - After the root token and key shares are generated click the _Download keys_ link and download a json file containing the aforementioned tokes. click **Continue to Unseal** to proceed the setup.
      > **Important**: Secure the file with tokens or the token as it will be used for accessing and managing the vault content.

    - Enter 3 out of 5 master key portions from the json file one by one to unseal the vault and click **Unseal** to proceed.

    - Choose _Token_ as the authentication method and enter the root token from the json file. click **Sign in** to proceed.

3. Enable KVv2 secrets engine

    > There is a variety of [secret engines](https://www.vaultproject.io/docs/secrets/index.html) supported by Vault designated for different use cases. **KVv2** (key/value) secret engine is used to store arbitrary secrets within the configured physical storage for Vault.

    - click the _Secrets_ menu in the top right corner to navigate to the secrets management console. Then click _Enable new engine_ to proceed.

    - Choose **KV** as a secrets engine and click **Next** to proceed. Set _Path_ to `secrets` and _Version_ to `2` (default KV engine version). Check the [KV engine documentation](https://www.vaultproject.io/docs/secrets/kv/kv-v2.html) for the engine options details and modify if necessary. click **Enable Engine** to finish the setup.


4. <a name="create-a-secret"></a>Create a secret

    > The secret will be used by a continues integration server for a test build.

    - Navigate to `Secrets -> secrets` to open the secret management console then click _Create secret_.

    - Set _Path for this secret_ to `ci.build.sample` and create a single entry version data with the following key/value pair `HELLO_WORLD`/`Hello world!`. click **Save** to save changes.

5. Configure machine identity access

    > Check [AppRole Pull Authentication](https://learn.hashicorp.com/vault/identity-access-management/iam-authentication) for more information.

    - Enable the AppRole authentication method. Navigate to `Access`, then choose the _AppRole_ option from the list and click **Next** to continue. Click `Expand Method` to expand the options section and set _Default Lease TTL_ and  _Max Lease TTL_ to **30 days**. Leave the _Path_ value (expected to be `approle`) click **Enable Method** to finish.

    - <a id="acl-policy"></a>Create a policy for authenticating with role credentials and accessing secrets. Navigate to `Policies` and click **Create ACL policy**. Set the _Name_ field to `ciagent` and copy-paste the configuration bellow into the _Policy_ field.
    
        > `approle` is the alias for the _AppRole_ authentication method enabled earlier. In case a different alias is chosen make sure to correct the `path` value for login policy.
        
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
    
    -  Create a role linked with the policy and generate a secret id for that role. Click the Vault CLI shell icon (![Alt text](/resources/img/vault_shell.png?raw=true "Vault shell")) in the top right corner to open the command shell. Execute the following commands in the UI shell.

        - Create a new `ciagent` role and link it to the `ciagent` policy.
            ```
            > vault write auth/approle/role/ciagent policies="ciagent, default"
            ```

        - Read Role ID. The Role ID is used for issuing an access token.
            ```
            > vault read auth/approle/role/ciagent/role-id
            ```

        -  Generate a new Secret ID for the `ciagent` role. The output of the command should contain `secret_id` which is used as a password and must be capture for later use.
            ```
            > vault write -force auth/approle/role/ciagent/secret-id
            ```

        - If the Secret ID was not captured or lost the only way to restore is to regenerate a new one. Run the following command to list available *secret_id_accessor*s.

            ```
            > vault list auth/approle/role/ciagent/secret-id 
            ```

            Use the _secret_id_accessor_ value from the output and run the following command to remove the Secret ID .
            > Replace `[secret-id]` with the actual *secret_id_accessor* value from the output.

            ```
            > vault write auth/approle/role/ciagent/secret-id/destroy secret_id="[secret-id]"
            ```

            Generate a new Secret ID as described in the previous step.

    - <a name="issue-a-client-token"></a> Issue a client token. Type `api` in the UI shell and press the `Enter` key to open _Vault API explorer_. 
        
        -  Find `POST /auth/approle/login/` and click on the section to expand it, then click **Try it out** to enable editing.
        
        -  Fill in request body parameters with matching `role_id` and `secret_id` values then click **Execute - send a request with your token to Vault**. Follow the checklist:

            - [x] Response code is `200`
            - [x] The response body contains correct `role_name` and `token_policies` values
            - [x] The response body contains `client_token`, `lease_duration` is set to _2592000_ and `renewable` is _true_

            Proceed if the checks are passed, otherwise consult with the Vault documentation.
            
        - Extract and save the `client_token` value, it will be used further for configuring the integration between ci and vault servers. Run the following command to set an environment variable for the vault token.
            > Replace `[client_token]` with the actual vault token value.

            ```
            export VAULT_TOKEN=[client_token]
            ```
            Run `echo $VAULT_TOKEN` to verify if the variable is set.
