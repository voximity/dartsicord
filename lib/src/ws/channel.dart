import "dart:async";
import "../internals.dart";
import "../client.dart";
import "guild.dart";
import "message.dart";
import "user.dart";

abstract class Channel extends DiscordObject {
  String name;
  int id;
}



class TextChannel extends DiscordObject implements Channel {
  String name;
  int id;

  Future sendMessage(String content) async => client.sendMessage(content, this);

  TextChannel(this.name, this.id);

  static TextChannel fromDynamic(dynamic obj, DiscordClient client) {
    if (obj["type"] != 0)
      return null;
    return new TextChannel(obj["name"], obj["id"])..client = client;
  }
}

class GuildTextChannel extends DiscordObject implements TextChannel {
  String name;
  int id;

  Guild guild;

  Future sendMessage(String content) async => client.sendMessage(content, this);

  static TextChannel fromDynamic(dynamic obj, DiscordClient client) {
    return new TextChannel(obj["name"], obj["id"])..client = client;
  }
}

class VoiceChannel extends DiscordObject implements Channel {
  String name;
  int id;

  Guild guild;
}