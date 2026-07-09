/**
 * Test class for UnsplashService.searchImage, covering the success, empty-
 * results, and error-response paths via HttpCalloutMock stand-ins for the
 * real Unsplash API callout.
 */
@isTest
private class UnsplashServiceTest {
  /** Mock HTTP response simulating a successful Unsplash search with one result. */
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

  /** Mock HTTP response simulating a successful Unsplash search with zero results. */
  private class EmptyResultsMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"results":[]}');
      res.setStatusCode(200);
      return res;
    }
  }

  /** Mock HTTP response simulating an Unsplash API error (401 Unauthorized). */
  private class ErrorMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(401);
      return res;
    }
  }

  /**
   * Scenario: searchImage() is called while UnsplashMock is set, simulating
   * an Unsplash response with one matching photo result.
   * Expected outcome: the returned URL matches the mocked "regular" image URL.
   */
  @isTest
  static void testSearchImageSuccess() {
    Test.setMock(HttpCalloutMock.class, new UnsplashMock());

    Test.startTest();
    String imageUrl = UnsplashService.searchImage('Laptop');
    Test.stopTest();

    System.assertEquals('https://images.unsplash.com/test.jpg', imageUrl);
  }

  /**
   * Scenario: searchImage() is called while EmptyResultsMock is set, simulating
   * a successful Unsplash response with no matching photos.
   * Expected outcome: the method returns null.
   */
  @isTest
  static void testSearchImageNoResults() {
    Test.setMock(HttpCalloutMock.class, new EmptyResultsMock());

    Test.startTest();
    String imageUrl = UnsplashService.searchImage('Xyz123NoSuchThing');
    Test.stopTest();

    System.assertEquals(null, imageUrl);
  }

  /**
   * Scenario: searchImage() is called while ErrorMock is set, simulating an
   * Unsplash API error response (HTTP 401).
   * Expected outcome: the method returns null rather than throwing.
   */
  @isTest
  static void testSearchImageErrorResponse() {
    Test.setMock(HttpCalloutMock.class, new ErrorMock());

    Test.startTest();
    String imageUrl = UnsplashService.searchImage('Laptop');
    Test.stopTest();

    System.assertEquals(null, imageUrl);
  }
}
