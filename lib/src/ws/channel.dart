import "dart:async";
import "../internals.dart";
import "../client.dart";
import "guild.dart";
import "message.dart";
import "user.dart";
import "embed.dart";

abstract class Channel extends DiscordObject {
  /// Name of the channel.
  String name;

  int id;
}

class TextChannel extends DiscordObject implements Channel {
  String name;
  int id;

  /// Guild of the channel, if any.
  Guild guild;

  /// Send a message to the channel.
  Future<Message> sendMessage(String content, {Embed embed}) async => client.sendMessage(content, this, embed: embed);

  TextChannel(this.name, this.id);

  static TextChannel fromDynamic(dynamic obj, DiscordClient client, {Guild guild}) {
    if (obj["type"] != 0)
      return null;
    
    final channel = new TextChannel(obj["name"], obj["id"])
      ..client = client
      ..guild = guild != null ? guild : (obj["guild_id"] != null ? client.getGuild(obj["guild_id"]) : null);
    return channel;
  }
}

class VoiceChannel extends DiscordObject implements Channel {
  String name;
  int id;

  Guild guild;
}