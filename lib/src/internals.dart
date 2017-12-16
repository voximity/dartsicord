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

  Future<http.Response> get({Map<String, String> headers, DiscordClient client}) async =>
    http.get(url, headers: authHeader(header: headers, client: client));
  Future<http.Response> delete({Map<String, String> headers, DiscordClient client}) async =>
    http.delete(url, headers: authHeader(header: headers, client: client));
  Future<http.Response> post(dynamic body, {Map<String, String> headers, DiscordClient client}) async =>
    http.post(url, body: JSON.encode(body), headers: authHeader(header: headers, client: client));
  Future<http.Response> patch(dynamic body, {Map<String, String> headers, DiscordClient client}) async =>
    http.patch(url, body: JSON.encode(body), headers: authHeader(header: headers, client: client));
  Future<http.Response> put(dynamic body, {Map<String, String> headers, DiscordClient client}) async =>
    http.put(url, body: JSON.encode(body), headers: authHeader(header: headers, client: client));
}

class Packet {
  int opcode;
  int seq;
  dynamic data;
  String event;

  Packet({this.opcode = 1, this.data, this.seq = null, this.event});

  String toString() => JSON.encode({"op": opcode, "d": data, "s": seq, "t": event});
}