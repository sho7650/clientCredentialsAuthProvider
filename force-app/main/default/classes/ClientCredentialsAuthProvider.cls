global class ClientCredentialsAuthProvider extends Auth.AuthProviderPluginClass {
    // define
    public static final String CUSTOM_MDT_NAME = 'ClientCredentials_Metadata__mdt';
    public static final String CALLBACK_URL = '/services/authcallback/';
    public static final String GRANT_TYPE = 'client_credentials';

    public static final String CMDT_FIELD_PROVIDER_NAME = 'Auth_provider__c';
    public static final String CMDT_FIELD_ACCESS_TOKEN_URL = 'Access_Token_URL__c';
    public static final String CMDT_FIELD_CLIENT_ID = 'Client_ID__c';
    public static final String CMDT_FIELD_CLIENT_SECRET = 'Client_Secret__c';
    public static final String CMDT_FIELD_USER_NAME = 'User_Name__c';

    // access token response
    private class TokenResponse {
        public String access_token;     //required
        public String token_type;       //required
        public Long expires_in;         //recommended
        public String refresh_token;    //optional
        public String scope;            //optional
        public String error;            //in case of error
        public String error_description;//in case of error
        public String error_uri;        //in case of error

        public Boolean isError() {
            return error != null;
        }

        public String getErrorMessage() {
            return error;
        }
    }

    global String getCustomMetadataType() {
        return CUSTOM_MDT_NAME;
    }

    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
        final PageReference pageRef = new PageReference(getCallbackUrl(authProviderConfiguration));
        pageRef.getParameters().put('state',stateToPropagate);

        return pageRef;
    }

    private String getCallbackUrl(Map<string,string> config) {
        return URL.getSalesforceBaseUrl().toExternalForm() + CALLBACK_URL + config.get(CMDT_FIELD_PROVIDER_NAME);
    }

    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState callbackState) {
        TokenResponse tokenResponse = retrieveToken(authProviderConfiguration);

        if (tokenResponse.isError()) {
            throw new TokenException(tokenResponse.getErrorMessage());
        }

        return new Auth.AuthProviderTokenResponse(
            authProviderConfiguration.get(CMDT_FIELD_PROVIDER_NAME),    // provider
            tokenResponse.access_token,                                 // oauthToken
            'refreshToken',                                             // oauthSecretOrRefreshToken
            callbackState.queryParameters.get('state')                  // state
        );
    }

    global Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {
        String userName = authProviderConfiguration.get(CMDT_FIELD_USER_NAME);
        String provider = authProviderConfiguration.get(CMDT_FIELD_PROVIDER_NAME);
        return new Auth.UserData(
            null,       // identifier
            null,       // firstName
            null,       // lastName
            null,       // fullName
            userName,   // email
            null,       // link
            userName,   // userName
            null,       // locale
            provider,   // provider
            null,       // siteLoginUrl
            new Map<String,String>()
        );
    }

    override global Auth.OAuthRefreshResult refresh(Map<String,String> authProviderConfiguration, String refreshToken) {
        TokenResponse tokenResponse = retrieveToken(authProviderConfiguration);
        return new Auth.OAuthRefreshResult(tokenResponse.access_token, tokenResponse.token_type);
    }

    private TokenResponse retrieveToken(Map<String,String> config) {
        String access_token_url = config.get(CMDT_FIELD_ACCESS_TOKEN_URL);
        String parameters =   'client_id=' + config.get(CMDT_FIELD_CLIENT_ID)
                            + '&client_secret=' + config.get(CMDT_FIELD_CLIENT_SECRET)
                            + '&grant_type=' + GRANT_TYPE;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(access_token_url);
        req.setHeader('Content-Type','application/x-www-form-urlencoded;charset=UTF-8');
        req.setMethod('POST');
        req.setBody(parameters);
        Http http = new Http();

        HTTPResponse res = http.send(req);
        return (TokenResponse)JSON.deserialize(res.getBody(), TokenResponse.class);
    }

    public class TokenException extends Exception { }
}