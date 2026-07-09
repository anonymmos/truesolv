public with sharing class UnsplashService {
  private static final String ACCESS_KEY = 'Rbr0KOAfvEt27fn3-UG7vczdkdDW9OQLoWit4e4d4e8';

  @AuraEnabled
  public static String searchImage(String itemName) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();

    request.setMethod('GET');
    request.setEndpoint(
      'https://api.unsplash.com/search/photos?query=' +
        EncodingUtil.urlEncode(itemName, 'UTF-8') +
        '&per_page=1'
    );
    request.setHeader('Authorization', 'Client-ID ' + ACCESS_KEY);

    HttpResponse response = http.send(request);

    if (response.getStatusCode() != 200) {
      return null;
    }

    Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(
      response.getBody()
    );
    List<Object> results = (List<Object>) body.get('results');

    if (results.isEmpty()) {
      return null;
    }

    Map<String, Object> firstResult = (Map<String, Object>) results[0];
    Map<String, Object> urls = (Map<String, Object>) firstResult.get('urls');

    return (String) urls.get('regular');
  }
}
