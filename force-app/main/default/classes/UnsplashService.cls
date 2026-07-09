/**
 * Service class for retrieving a representative image from the Unsplash API,
 * used to auto-populate an Item__c's Image__c field on creation.
 */
public with sharing class UnsplashService {
  private static final String ACCESS_KEY = 'Rbr0KOAfvEt27fn3-UG7vczdkdDW9OQLoWit4e4d4e8';

  /**
   * Searches Unsplash for a single photo matching the given item name and
   * returns its "regular" size image URL.
   *
   * @param itemName String search query (e.g. an item's Name), URL-encoded
   *   internally before being sent to the Unsplash API.
   * @return String the matching photo's regular-size image URL, or null if the
   *   HTTP response status is not 200 or no results are returned.
   * Side effects: performs an outbound HTTP callout to api.unsplash.com. Requires
   *   a corresponding remote site setting / named credential authorization for
   *   the callout to succeed.
   */
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
