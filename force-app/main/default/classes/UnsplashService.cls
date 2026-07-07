public with sharing class UnsplashService {
  @AuraEnabled
  public static String searchImage(String itemName) {
    Http http = new Http();

    HttpRequest request = new HttpRequest();

    request.setMethod('GET');

    request.setEndpoint(
      'https://api.unsplash.com/search/photos?query=' +
      EncodingUtil.urlEncode(itemName, 'UTF-8')
    );

    HttpResponse response = http.send(request);

    return response.getBody();
  }
}
