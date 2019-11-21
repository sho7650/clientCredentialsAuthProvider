
@isTest(isParallel=true)
public class ClientCredentialsAuthProviderTest {
  // unitTest data
  private static final String PROVIDER_NAME = 'UnitTestAuthProvider';
  private static final String ACCESS_TOKEN_URL = 'http://www.example.com/token/dummy';
  private static final String CLIENT_ID = 'testID';
  private static final String CLIENT_SECRET ='testSecret';
  private static final String USER_NAME = 'test@example.com';

  private static final String STATE_TO_PROPOGATE = 'testState';
  private static final String ACCESS_TOKEN = 'thisIsTestAccessToken';
  private static final String STATE = 'testState';

  private static final String correctJsonToken = '{'+
'  \"token_type\" : \"Bearer\",'+
'  \"access_token\" : \"thisIsTestAccessToken\",'+
'  \"expires_in\" : \"3599\",'+
'}';

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

  // todo: create httpMockService and assert UserInfo
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
    System.assertEquals(expectedUserData.firstName, actualUserData.firstName);
    System.assertEquals(expectedUserData.lastName, actualUserData.lastName);
    System.assertEquals(expectedUserData.fullName, actualUserData.fullName);
    System.assertEquals(expectedUserData.email, actualUserData.email);
    System.assertEquals(expectedUserData.username, actualUserData.username);
    System.assertEquals(expectedUserData.locale, actualUserData.locale);
    System.assertEquals(expectedUserData.provider, actualUserData.provider);
    System.assertEquals(expectedUserData.siteLoginUrl, actualUserData.siteLoginUrl);

  }
}