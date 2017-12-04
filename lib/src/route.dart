import "package:http/http.dart" as http;

import "client.dart";

import "dart:async";

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
  Future<http.Response> post(dynamic body, {dynamic headers}) async => http.post(url, body: body, headers: headers);
}