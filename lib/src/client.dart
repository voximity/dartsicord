import "package:http/http.dart" as http;

import "dart:async";

import "route.dart";

class DiscordClient {
  String _token;

  Future _getGateway() async {
    var route = new Route(this);
  }

  DiscordClient() {

  }

  Future connect(String token) async {
    _token = token;
  }
}