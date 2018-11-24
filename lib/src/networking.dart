part of '../dartsicord.dart';

class _Route {
  String url = "https://discordapp.com/api";
  DiscordClient client;

  _Route({this.client});

  _Route operator +(dynamic other) =>
      new _Route(client: client)..url = url + "/" + other.toString();

  Map<String, String> authHeader({Map<String, String> header}) => ({
        "Authorization": (client.tokenType == TokenType.bot ? "Bot " : "") +
            "${client.token}",
        "Content-Type": "application/json"
      })
        ..addAll(header ?? {});

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

  Future<http.Response> get({Map<String, String> headers}) async {
    final response = await http.get(url, headers: authHeader(header: headers));
    handleStatusCode(response);
    return response;
  }

  Future<http.Response> delete({Map<String, String> headers}) async {
    final response =
        await http.delete(url, headers: authHeader(header: headers));
    handleStatusCode(response);
    return response;
  }

  Future<http.Response> post(dynamic body,
      {Map<String, String> headers}) async {
    final response = await http.post(url,
        body: json.encode(body), headers: authHeader(header: headers));
    handleStatusCode(response);
    return response;
  }

  Future<http.Response> patch(dynamic body,
      {Map<String, String> headers}) async {
    final response = await http.patch(url,
        body: json.encode(body), headers: authHeader(header: headers));
    handleStatusCode(response);
    return response;
  }

  Future<http.Response> put(dynamic body, {Map<String, String> headers}) async {
    final response = await http.put(url,
        body: json.encode(body), headers: authHeader(header: headers));
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

  Packet({this.opcode, this.data, this.seq, this.event, this.client});

  String toString() =>
      json.encode({"op": opcode, "d": data, "s": seq, "t": event});
}
