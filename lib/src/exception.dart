class NotAuthorException implements Exception {
  NotAuthorException() : super();
}

abstract class HttpResponseException implements Exception {

}
class UnauthorizedException implements HttpResponseException {

}
class ForbiddenException implements HttpResponseException {
   
}