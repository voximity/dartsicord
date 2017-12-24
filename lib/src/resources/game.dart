import "dart:async";

import "../client.dart";
import "../enums.dart";
import "../object.dart";

class Game extends DiscordObject {
  static Map<String, StatusType> statuses = {
    "online": StatusType.online,
    "dnd": StatusType.doNotDisturb,
    "idle": StatusType.away,
    "invisible": StatusType.invisible,
    "offline": StatusType.offline
  };
  static Map<int, ActivityType> activities = {
    0: ActivityType.game,
    1: ActivityType.stream,
    2: ActivityType.listen,
    3: ActivityType.watch
  };
  static Map<ActivityType, int> get activitiesR =>
    new Map.fromIterables(activities.values, activities.keys);
  static Map<StatusType, String> get statusesR =>
    new Map.fromIterables(statuses.values, statuses.keys);

  String name;
  Uri streamUrl;
  ActivityType type;

  Game(this.name, this.type, {this.streamUrl});

  Future<Game> fromMap(Map<String, dynamic> obj, DiscordClient client) async =>
    new Game(obj["name"], Game.activities[obj["type"]],
      streamUrl: obj["url"] != null ? Uri.parse(obj["url"]) : null)
      ..client = client;
  
  Map<String, dynamic> toMap() =>
    {
      "name": name,
      "type": Game.activitiesR[type],
      "url": streamUrl?.toString()
    };
}

