### Static (working)

`ANTHROPIC_API_KEY` to use the openai helm chart, you will need an anthropic api key. There are two ways to configure this, the simplest approach is to use a master api key where all openai requests use the same key
for all requests. This is the quickest way to get up and running.

1. login to your anthropic  account and create an api key for your account
2. touch .api-key`
3. place the api key in the file `.api-key` in the root of the helm project

### Vault (in development)
The second approach is to configure the secrets under the processor vault section at runtime (see alethic-ism-vault-api - TBD, this is currently still in development). This is the preferred approach as it allows for more granular control over the api keys and allows for different keys to be used for different users, projects and even processors. **Note** The openai processor will use the secrets configured in the vault to make requests to the openai api. This is still in development and will be added in a future release.

