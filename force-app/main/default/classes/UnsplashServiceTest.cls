@isTest
private class UnsplashServiceTest {
  private class UnsplashMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"results":[{"urls":{"regular":"https://images.unsplash.com/test.jpg"}}]}'
      );
      res.setStatusCode(200);
      return res;
    }
  }

  private class EmptyResultsMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"results":[]}');
      res.setStatusCode(200);
      return res;
    }
  }

  private class ErrorMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(401);
      return res;
    }
  }

  @isTest
  static void testSearchImageSuccess() {
    Test.setMock(HttpCalloutMock.class, new UnsplashMock());

    Test.startTest();
    String imageUrl = UnsplashService.searchImage('Laptop');
    Test.stopTest();

    System.assertEquals('https://images.unsplash.com/test.jpg', imageUrl);
  }

  @isTest
  static void testSearchImageNoResults() {
    Test.setMock(HttpCalloutMock.class, new EmptyResultsMock());

    Test.startTest();
    String imageUrl = UnsplashService.searchImage('Xyz123NoSuchThing');
    Test.stopTest();

    System.assertEquals(null, imageUrl);
  }

  @isTest
  static void testSearchImageErrorResponse() {
    Test.setMock(HttpCalloutMock.class, new ErrorMock());

    Test.startTest();
    String imageUrl = UnsplashService.searchImage('Laptop');
    Test.stopTest();

    System.assertEquals(null, imageUrl);
  }
}
