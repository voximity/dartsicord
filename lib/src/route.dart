import "package:http/http.dart" as http;

import "package:discord/discord.dart";

import "dart:async";

class Route {
  String url = "https://discordapp.com/api";
  String auth = "";

  Route(DiscordClient client) {
    auth = "Bot ${client._token}";
  }

  operator +(String other) {
    url += "/$other";
    return this;
  }
  Future get({dynamic headers}) async => http.get(url, headers: headers);
  Future post(dynamic body, {dynamic headers}) async => http.post(url, body: body, headers: headers);
}