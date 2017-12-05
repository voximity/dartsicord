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

  Future<http.Response> get({dynamic headers}) async => http.get(url, headers: headers);
  Future<http.Response> post(dynamic body, {Map<String, String> headers}) async => http.post(url, body: body, headers: headers);
}

class Packet {
  int opcode;
  int seq;
  dynamic data;
  String event;

  Packet({this.opcode = 1, this.data, this.seq = null, this.event});

  String toString() => JSON.encode({"op": opcode, "d": data, "s": seq, "t": event});
}