import "../client.dart";
import "../object.dart";
import "../enums.dart";

import "dart:async";

class Game extends DiscordObject {
  String name;
  Uri streamUrl;
  ActivityType type;

  Game(this.name, this.type, {this.streamUrl});

  Future<Game> fromMap(Map<String, dynamic> obj, DiscordClient client) async =>
    new Game(obj["name"], EnumMaps.activityMap[obj["type"]],
      streamUrl: obj["url"] != null ? Uri.parse(obj["url"]) : null)
      ..client = client;
  
  Map<String, dynamic> toMap() =>
    {
      "name": name,
      "type": EnumMaps.activityMapReverse[type],
      "url": streamUrl?.toString()
    };
}

