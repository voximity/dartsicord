enum ChannelType {
  GuildText,
  Dm,
  GuildVoice,
  GroupDm,
  GuildCategory
}

enum TokenType {
  Bot,
  User
}

enum StatusType {
  Online,
  DoNotDisturb,
  Away,
  Invisible,
  Offline
}

enum ActivityType {
  Game,
  Stream,
  Listen,
  Watch
}

class EnumMaps {

  static Map<String, StatusType> statusMap = {
    "online": StatusType.Online,
    "dnd": StatusType.DoNotDisturb,
    "idle": StatusType.Away,
    "invisible": StatusType.Invisible,
    "offline": StatusType.Offline
  };

  static Map<int, ActivityType> activityMap = {
    0: ActivityType.Game,
    1: ActivityType.Stream,
    2: ActivityType.Listen,
    3: ActivityType.Watch
  };
  
  static Map<StatusType, String> get statusMapReverse =>
    new Map.fromIterables(statusMap.values, statusMap.keys);
  static Map<ActivityType, int> get activityMapReverse =>
    new Map.fromIterables(activityMap.values, activityMap.keys);

}