import "package:http/http.dart" as http;

import "client.dart";

import "dart:async";
import "dart:convert";

class Route {
  String url = "https://discordapp.com/api";
  String auth = "";

  DiscordClient client;

  Route(this.client) {
    auth = "Bot ${client.token}";
  }

  Route operator +(String other) {
    url += "/$other";
    return this;
  }

  Map<String, String> authHeader({Map<String, String> header}) {
    if (header == null)
      header = {};

    header["Authorization"] = "Bot ${client.token}";
    header["Content-Type"] = "application/json";
    return header;
  }

  Future<http.Response> get({Map<String, String> headers}) async => http.get(url, headers: authHeader(header: headers));
  Future<http.Response> delete({Map<String, String> headers}) async => http.delete(url, headers: authHeader(header: headers));
  Future<http.Response> post(dynamic body, {Map<String, String> headers}) async => http.post(url, body: JSON.encode(body), headers: authHeader(header: headers));
  Future<http.Response> patch(dynamic body, {Map<String, String> headers}) async => http.patch(url, body: JSON.encode(body), headers: authHeader(header: headers));
  Future<http.Response> put(dynamic body, {Map<String, String> headers}) async => http.put(url, body: JSON.encode(body), headers: authHeader(header: headers));
}

class Packet {
  int opcode;
  int seq;
  dynamic data;
  String event;

  Packet({this.opcode = 1, this.data, this.seq = null, this.event});

  String toString() => JSON.encode({"op": opcode, "d": data, "s": seq, "t": event});
}