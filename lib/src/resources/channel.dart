import "dart:async";
import "dart:convert";

import "../client.dart";
import "../enums.dart";
import "../internals.dart";
import "../object.dart";

import "embed.dart";
import "guild.dart";
import "message.dart";
import "user.dart";

abstract class Channel extends DiscordObject {
  static Route endpoint = new Route() + "channels";
  Route get localEndpoint => Channel.endpoint + id.toString();
  
  /// Name of the channel.
  String name;

  /// Guild of the channel, if any.
  Guild guild;

  /// Type of the channel.
  ChannelType type;

  Snowflake id;

  /// A list of Channel types, by their API ID.
  static Map<int, ChannelType> types = {
    0: ChannelType.guildText,
    1: ChannelType.dm,
    2: ChannelType.guildVoice,
    3: ChannelType.groupDm,
    4: ChannelType.guildCategory
  };

  static Future<Channel> fromMap(Map<String, dynamic> obj, DiscordClient client) async {
    final type = obj["type"];
    if (type == 2)
      return VoiceChannel.fromMap(obj, client);
    else
      return TextChannel.fromMap(obj, client);
  }
}

class TextChannel extends Channel {
  String name;
  Snowflake id;

  ChannelType type;

  /// Guild of the channel, if any. Refer to the [type] property and check for [GuildText].
  Guild guild;
  
  /// Position of the channel. Refer to the [type] property and check for [GuildText].
  int position;

  String topic;

  bool nsfw;

  /// The recipient of this DM, if any. Refer to [type] property and check for [Dm].
  User get recipient => type == ChannelType.dm ? recipients.first : null;

  /// A list of recipients of this group DM, if any. Refer to [type] property and check for [GroupDm] or [Dm].
  List<User> recipients;

  Future<Null> delete() async =>
    await localEndpoint.delete(client: client);

  Future<Null> modify({String name, int position, String topic, bool nsfw}) async {
    final query = {
      "name": name,
      "position": position,
      "topic": topic,
      "nsfw": nsfw
    };
    
    final response = await localEndpoint.patch(query, client: client);
    final map = JSON.decode(response.body);

    this.name = map["name"];
    this.position = map["position"];
    this.topic = map["topic"];
    this.nsfw = map["nsfw"];
  }

  Future<Null> getMessages({int limit = 50, int before, int after, int around}) async {

  }

  /// Send a message to this channel.
  /// 
  /// Content is required. If you wish to send an embed, you must leave it blank ("").
  /// If you want to specify an embed, you first need to build an embed using the [Embed] object.
  /// Documentation for embed building is within the [Embed] object.
  Future<Message> sendMessage(String content, {Embed embed}) async {
    final route = localEndpoint + "messages";
    final response = await route.post({
      "content": content,
      "embed": embed != null ? embed.toMap() : null
    }, client: client);
    final parsed = JSON.decode(response.body);
    return (await Message.fromMap(parsed, client))..author = client.user;
  }

  TextChannel(this.name, this.id, this.type, {this.guild, this.recipients});

  static Future<TextChannel> fromMap(Map<String, dynamic> obj, DiscordClient client, {Guild guild}) async {
    final channelType = Channel.types[obj["type"]];
    switch (channelType) {
      case ChannelType.guildText:
        final channel = new TextChannel(obj["name"], new Snowflake(obj["id"]), channelType,
          guild: guild != null ? guild : (obj["guild_id"] != null ? client.getGuild(obj["guild_id"]) : null))
          ..client = client;
        return channel;

      case ChannelType.dm:
        final users = [];
        for (int i = 0; i < obj["recipients"].length; i++)
          users.add(await User.fromMap(obj["recipients"][i], client));
        final channel = new TextChannel("DM", new Snowflake(obj["id"]), channelType, recipients: users)
          ..client = client;
        return channel;

      case ChannelType.groupDm:
        final users = [];
        for (int i = 0; i < obj["recipients"].length; i++)
          users.add(await User.fromMap(obj["recipients"][i], client));
        final channel = new TextChannel("GroupDM", new Snowflake(obj["id"]), channelType, recipients: users)
          ..client = client;
        return channel;

      default:
        return null;
    }
  }
}

class VoiceChannel extends Channel {
  String name;
  Guild guild;

  Route get localEndpoint => Channel.endpoint + id;

  ChannelType type;

  Snowflake id;

  VoiceChannel(this.name, this.id);

  static Future<VoiceChannel> fromMap(Map<String, dynamic> obj, DiscordClient client, {Guild guild}) async {
    return null;
  }
}