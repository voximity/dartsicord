class NotAuthorException implements Exception {
  NotAuthorException() : super();
}

/// Base class for HTTP response exceptions.
abstract class HttpResponseException implements Exception {}

/// The request was improperly formatted, or the server couldn't understand it.
class BadRequestException implements HttpResponseException {}

/// The [token] provided was missing or invalid.
class UnauthorizedException implements HttpResponseException {}

/// The [token] provided does not have permission to the resource.
class ForbiddenException implements HttpResponseException {}

/// The resource at the location specified doesn't exist.
class NotFoundException implements HttpResponseException {}

/// The HTTP method used is not valid for the location specified. (library error?)
class MethodNotAllowedException implements HttpResponseException {}

/// You've made too many requests (you are ratelimited)
class TooManyRequestsException implements HttpResponseException {}

/// There was not a gateway available to process your request. Wait a bit and retry.
class GatewayUnavailableException implements HttpResponseException {}

/// The server had an error processing your request. (these are rare)
class ServerErrorException implements HttpResponseException {}