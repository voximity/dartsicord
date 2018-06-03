part of dartsicord;

/// A Game resource. Can be self-assembled to set the game.
class Game extends _Resource {
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
  static Map<ActivityType, int> get activitiesInverse =>
    new Map.fromIterables(activities.values, activities.keys);
  static Map<StatusType, String> get statusesInverse =>
    new Map.fromIterables(statuses.values, statuses.keys);
  static Future<Game> _fromMap(Map<String, dynamic> obj, DiscordClient client) async =>
    new Game(obj["name"], Game.activities[obj["type"]],
      streamUrl: obj["url"] != null ? Uri.parse(obj["url"]) : null)
      ..client = client;

  String name;
  Uri streamUrl;
  ActivityType type;

  Game(this.name, this.type, {this.streamUrl});
  
  Map<String, dynamic> _toMap() =>
    {
      "name": name,
      "type": Game.activitiesInverse[type],
      "url": streamUrl?.toString()
    };
}

