import "package:http/http.dart" as http;

import "client.dart";
import "exception.dart";
import "enums.dart";

import "dart:async";
import "dart:convert";

class Route {
  String url = "https://discordapp.com/api";

  Route();

  Route operator +(String other) =>
    new Route()..url = url + "/$other";

  Map<String, String> authHeader({Map<String, String> header, DiscordClient client}) {
    if (header == null)
      header = {};

    if (client != null)
      header["Authorization"] = (client.tokenType == TokenType.Bot ? "Bot " : "") + "${client.token}";
    header["Content-Type"] = "application/json";
    return header;
  }
  void handleStatusCode(http.Response response) {
    switch (response.statusCode) {
      case 200: // OK
        break;
      case 201: // CREATED
        break;
      case 204: // NO CONTENT
        break;
      case 304: // NOT MODIFIED
        break;
      case 400: // BAD REQUEST
        throw new BadRequestException();
      case 401: // UNAUTHORIZED
        throw new UnauthorizedException();
      case 403: // FORBIDDEN
        throw new ForbiddenException();
      case 404: // NOT FOUND
        throw new NotFoundException();
      case 405: // METHOD NOT ALLOWED
        throw new MethodNotAllowedException();
      case 429: // TOO MANY REQUESTS
        throw new TooManyRequestsException();
      case 502: // GATEWAY UNAVAILABLE
        throw new GatewayUnavailableException();
      default: // 5xx
        throw new ServerErrorException();
    }
  }

  Future<http.Response> get({Map<String, String> headers, DiscordClient client}) async {
    final response = await http.get(url, headers: authHeader(header: headers, client: client));
    handleStatusCode(response);
    return response;
  }
  Future<http.Response> delete({Map<String, String> headers, DiscordClient client}) async {
    final response = await http.delete(url, headers: authHeader(header: headers, client: client));
    handleStatusCode(response);
    return response;
  }
  Future<http.Response> post(dynamic body, {Map<String, String> headers, DiscordClient client}) async {
    final response = await http.post(url, body: JSON.encode(body), headers: authHeader(header: headers, client: client));
    handleStatusCode(response);
    return response;
  }
  Future<http.Response> patch(dynamic body, {Map<String, String> headers, DiscordClient client}) async {
    final response = await http.patch(url, body: JSON.encode(body), headers: authHeader(header: headers, client: client));
    handleStatusCode(response);
    return response;
  }
  Future<http.Response> put(dynamic body, {Map<String, String> headers, DiscordClient client}) async {
    final response = await http.put(url, body: JSON.encode(body), headers: authHeader(header: headers, client: client));
    handleStatusCode(response);
    return response;
  }
}

class Packet {
  DiscordClient client;
  int opcode;
  int seq;
  dynamic data;
  String event;

  Packet({this.opcode = 1, this.data, this.seq = null, this.event, this.client});

  String toString() => JSON.encode({"op": opcode, "d": data, "s": seq, "t": event});
}