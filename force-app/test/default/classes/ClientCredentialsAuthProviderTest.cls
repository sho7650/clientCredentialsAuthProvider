
@isTest(isParallel=true)
public class ClientCredentialsAuthProviderTest {
  // unitTest data
  private static final String PROVIDER_NAME = 'UnitTestAuthProvider';
  private static final String ACCESS_TOKEN_URL = 'http://www.example.com/token/dummy';
  private static final String CLIENT_ID = 'testID';
  private static final String CLIENT_SECRET ='testSecret';
  private static final String USER_NAME = 'test@example.com';
  private static final String TOKEN_TYPE = 'Bearer';

  private static final String STATE_TO_PROPOGATE = 'testState';
  private static final String ACCESS_TOKEN = 'thisIsTestAccessToken';
  private static final String STATE = 'testState';

  private static final String correctJsonToken = '{'+
'  \"token_type\": \"Bearer\",'+
'  \"access_token\": \"thisIsTestAccessToken\",'+
'  \"expires_in\": \"3599\"'+
'}';
  private static final String incorrectJsonToken = '{'+
  '  \"error\": \"invalid_request\",'+
  '  \"error_description\": \"error description\",'+
  '  \"error_uri\": \"see at https://example.com/\"'+
  '}';
  private static final Integer correctStatusCode = 200;
  private static final Integer invalidStatusCode = 400;

  @isTest static void getCustomMetadataTypeTest() {
    final ClientCredentialsAuthProvider provider = new ClientCredentialsAuthProvider();
    final String actual = provider.getCustomMetadataType();
    final String expected = ClientCredentialsAuthProvider.CUSTOM_MDT_NAME;
    System.assertEquals(expected, actual);
  }

  // define custom metadata fields
  private static Map<String,String> setupAuthProviderConfig() {
    final Map<String,String> authProviderConfiguration = new Map<String,String>();
    authProviderConfiguration.put(ClientCredentialsAuthProvider.CMDT_FIELD_PROVIDER_NAME, PROVIDER_NAME);
    authProviderConfiguration.put(ClientCredentialsAuthProvider.CMDT_FIELD_ACCESS_TOKEN_URL, ACCESS_TOKEN_URL);
    authProviderConfiguration.put(ClientCredentialsAuthProvider.CMDT_FIELD_CLIENT_ID, CLIENT_ID);
    authProviderConfiguration.put(ClientCredentialsAuthProvider.CMDT_FIELD_CLIENT_SECRET,CLIENT_SECRET);
    authProviderConfiguration.put(ClientCredentialsAuthProvider.CMDT_FIELD_USER_NAME,USER_NAME);

    return authProviderConfiguration;
  }

  @isTest static void initiateTest() {
    final Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
    final ClientCredentialsAuthProvider provider = new ClientCredentialsAuthProvider();

    final PageReference expectedUrl = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + ClientCredentialsAuthProvider.CALLBACK_URL + PROVIDER_NAME);
    expectedUrl.getParameters().put('state', STATE_TO_PROPOGATE);

    final PageReference actualUrl = provider.initiate(authProviderConfiguration, STATE_TO_PROPOGATE);
    System.assertEquals(expectedUrl.getParameters().get('state'), actualUrl.getParameters().get('state'));
  }

  // handle callback test - positive
  @isTest static void handleCallbackTest() {
    final Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
    final ClientCredentialsAuthProvider provider = new ClientCredentialsAuthProvider();

    Test.setMock(HttpCalloutMock.class, new ClientCredentialsMockService(correctJsonToken, correctStatusCode));

    final Map<String, String> queryParameters = new Map<String, String>();
    queryParameters.put('state', STATE);

    final Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(null, null, queryParameters);
    final Auth.AuthProviderTokenResponse actualAuthProviderTokenResponse = provider.handleCallback(authProviderConfiguration, callbackState);
    final Auth.AuthProviderTokenResponse expectedAuthProviderTokenResponse = new Auth.AuthProviderTokenResponse(PROVIDER_NAME, ACCESS_TOKEN, 'refreshToken', STATE);

    System.assertEquals(expectedAuthProviderTokenResponse.provider, actualAuthProviderTokenResponse.provider);
    System.assertEquals(expectedAuthProviderTokenResponse.oauthToken, actualAuthProviderTokenResponse.oauthToken);
    System.assertEquals(expectedAuthProviderTokenResponse.oauthSecretOrRefreshToken, actualAuthProviderTokenResponse.oauthSecretOrRefreshToken);
    System.assertEquals(expectedAuthProviderTokenResponse.state, actualAuthProviderTokenResponse.state);
  }

  // handle callback test - negative
  @isTest static void handleCallbackErrorTest() {
    final Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
    final ClientCredentialsAuthProvider provider = new ClientCredentialsAuthProvider();

    Test.setMock(HttpCalloutMock.class, new ClientCredentialsMockService(incorrectJsonToken, invalidStatusCode) );

    final Map<String, String> queryParameters = new Map<String, String>();
    queryParameters.put('state', STATE);

    final Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(null, null, queryParameters);
    try {
      final Auth.AuthProviderTokenResponse actualAuthProviderTokenResponse = provider.handleCallback(authProviderConfiguration, callbackState);
      System.Assert(false);
    } catch (ClientCredentialsAuthProvider.TokenException e) {
      System.assertEquals('invalid_request', e.getMessage());
    }

  }
  @isTest static void refreshTest() {
    final Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
    final ClientCredentialsAuthProvider provider = new ClientCredentialsAuthProvider();

    Test.setMock(HttpCalloutMock.class, new ClientCredentialsMockService(correctJsonToken, correctStatusCode));

    final Auth.OAuthRefreshResult actual = provider.refresh(authProviderConfiguration, 'refreshToken');
    final Auth.OAuthRefreshResult expected = new Auth.OAuthRefreshResult(ACCESS_TOKEN, TOKEN_TYPE);

    System.assertEquals(expected.accessToken, actual.accessToken);
    System.assertEquals(expected.refreshToken, actual.refreshToken);
    System.assertEquals(expected.error, actual.error);
  }

  @isTest static void getUserInfoTest() {
    final Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
    final ClientCredentialsAuthProvider provider = new ClientCredentialsAuthProvider();

    Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(PROVIDER_NAME, ACCESS_TOKEN, 'refresh', STATE);
    Auth.UserData actualUserData = provider.getUserInfo(authProviderConfiguration, response);

    final Auth.UserData expectedUserData = new Auth.UserData(
      null,         // identifier
      null,         // firstName
      null,         // lastName
      null,         // fullName
      USER_NAME,    // email
      null,         // link
      USER_NAME,    // userName
      null,         // locale
      PROVIDER_NAME,// provider
      null,         // siteLoginUrl
      new Map<String,String>()
    );

    System.assertNotEquals(actualUserData,null);
    System.assertEquals(expectedUserData.firstName,     actualUserData.firstName);
    System.assertEquals(expectedUserData.lastName,      actualUserData.lastName);
    System.assertEquals(expectedUserData.fullName,      actualUserData.fullName);
    System.assertEquals(expectedUserData.email,         actualUserData.email);
    System.assertEquals(expectedUserData.username,      actualUserData.username);
    System.assertEquals(expectedUserData.locale,        actualUserData.locale);
    System.assertEquals(expectedUserData.provider,      actualUserData.provider);
    System.assertEquals(expectedUserData.siteLoginUrl,  actualUserData.siteLoginUrl);
  }

  public class ClientCredentialsMockService implements HttpCalloutMock {
    String jsonResponse;
    Integer statusCode;

    public ClientCredentialsMockService(String json, Integer code) {
      this.jsonResponse = json;
      this.statusCode = code;
    }

    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();

      res.setHeader('Content-Type', 'application/json');
      res.setBody(jsonResponse);
      res.setStatusCode(StatusCode);

      return res;
    }
  }
}