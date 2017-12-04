import "dart:async";
import "../route.dart";
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
}

class GuildTextChannel extends DiscordObject implements TextChannel {
  String name;
  int id;

  Guild guild;

  Future sendMessage(String content) async => client.sendMessage(content, this);
}

class VoiceChannel extends DiscordObject implements Channel {
  String name;
  int id;

  Guild guild;
}