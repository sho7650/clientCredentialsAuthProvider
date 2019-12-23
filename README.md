# Sample Client-Credentials Auth Provider Sample Code

## Dev, Build and Test

You should clone this code and deploy to Salesforce Org or DevHub.

1. download
```
$ git clone https://github.com/sho7650/clientCredentialsAuthProvider.git
$ cd ./clientCredentialsAuthProvider
```

2. authenticate your Org

in the case of DevHub
```
$ sfdx force:auth:web:login -d -a <alias your DevHub>
$ sfdx force:org:create -s -f config/project-scratch-def.json -a <alias your scratch Org>
```

3. deploy this code and test

```
$ sfdx force:source:push
```

run test example
```
$ sfdx force:apex:test:run --tests ClientCredentialsAuthProviderTest --resultformat human --outputdir .sfdx/tools/testresults/apex --loglevel error --codecoverage
=== Test Reports
FORMAT  FILE
──────  ──────────────────────────────────────────────────────────────────
txt     .sfdx/tools/testresults/apex/test-result.txt
txt     .sfdx/tools/testresults/apex/test-run-id.txt
junit   .sfdx/tools/testresults/apex/test-result-7070w00000FPnWD-junit.xml
json    .sfdx/tools/testresults/apex/test-result-7070w00000FPnWD.json
json    .sfdx/tools/testresults/apex/test-result-codecoverage.json

=== Apex Code Coverage
ID                  NAME                           % COVERED  UNCOVERED LINES
──────────────────  ─────────────────────────────  ─────────  ───────────────
01p0w000000ikK6AAI  ClientCredentialsAuthProvider  100%

=== Test Results
TEST NAME                                                    OUTCOME  MESSAGE  RUNTIME (MS)
───────────────────────────────────────────────────────────  ───────  ───────  ────────────
ClientCredentialsAuthProviderTest.getCustomMetadataTypeTest  Pass              10
ClientCredentialsAuthProviderTest.getUserInfoTest            Pass              6
ClientCredentialsAuthProviderTest.handleCallbackErrorTest    Pass              9
ClientCredentialsAuthProviderTest.handleCallbackTest         Pass              8
ClientCredentialsAuthProviderTest.initiateTest               Pass              7
ClientCredentialsAuthProviderTest.refreshTest                Pass              7

=== Test Summary
NAME                 VALUE
───────────────────  ─────────────────────────────────────────────────────
Outcome              Passed
Tests Ran            6
Passing              6
Failing              0
Skipped              0
Pass Rate            100%
Fail Rate            0%
Test Start Time      Dec 23, 2019 9:39 AM
Test Execution Time  47 ms
Test Total Time      47 ms
Command Time         6606 ms
Hostname             https://app-java-6006-dev-ed.cs75.my.salesforce.com/
Org Id               00D0w0000000R6tEAE
Username             test-clientcredentials@example.com
Test Run Id          7070w00000FPnWD
User Id              0050w000001JQyOAAW
Test Run Coverage    100%
Org Wide Coverage    100%
```

## Customise

You should customise this custom-meta-data to your Org and run this command.

```
$ ./bin/config.sh <your config>
```

### Descripton of config file

A sample config file. You need to define whole config vars.
```
ENDPOINT='https://test.example.com'
EXECUTION_USER='test@example.com'
REMOTE_SITE_URL='https://api.example.com'
ACCESS_TOKEN_URL='https://example.com/token'
CLIENT_ID='client_id'
CLIENT_SECRET='client_secret'
```

`ENDPOINT` ... call out endpoint URL using by Named Credentials
`EXECUTION_USER` ... username using connecting to remote site
`REMOTE_SITE_URL` ... would to access remote site URL
`ACCESS_TOKEN_URL` ... request access token URL with authorization server
`CLIENT_ID` ... identify apps
`CLIENT_SECRET` ... secret key known only to apps and authorization server