### OpenAI API KEY
To use the openai helm chart, you will need an openai api key. There are two ways to configure this, the simplest approach is to use a master api key where all openai requests use the same key
for all requests. This is the quickest way to get up and running.
1. login to openai and create an api key for your account
2. `touch .openai-api-key`
3. place the api key in the file `.openai-api-key` in the root of the helm project

The second approach is to configure the secrets under the processor vault section at runtime (see alethic-ism-vault-api - TBD

