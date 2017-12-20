import "dart:convert";
import "dart:async";

import "../internals.dart";
import "../client.dart";
import "../enums.dart";
import "../object.dart";

import "guild.dart";
import "message.dart";
import "user.dart";
import "embed.dart";

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
    0: ChannelType.GuildText,
    1: ChannelType.Dm,
    2: ChannelType.GuildVoice,
    3: ChannelType.GroupDm,
    4: ChannelType.GuildCategory
  };

  static Future<Channel> fromMap(Map<String, dynamic> obj, DiscordClient client) async {
    final type = obj["type"];
    if (type == 2)
      return VoiceChannel.fromMap(obj, client);
    else
      return TextChannel.fromMap(obj, client);
  }
}

class TextChannel extends DiscordObject implements Channel {
  String name;
  Snowflake id;
  Route get localEndpoint => Channel.endpoint + id;

  ChannelType type;

  /// Guild of the channel, if any. Refer to the [type] property and check for [GuildText].
  Guild guild;

  /// The recipient of this DM, if any. Refer to [type] property and check for [Dm].
  User get recipient => type == ChannelType.Dm ? recipients.first : null;

  /// A list of recipients of this group DM, if any. Refer to [type] property and check for [GroupDm] or [Dm].
  List<User> recipients;

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
      case ChannelType.GuildText:
        final channel = new TextChannel(obj["name"], new Snowflake(obj["id"]), channelType,
          guild: guild != null ? guild : (obj["guild_id"] != null ? client.getGuild(obj["guild_id"]) : null))
          ..client = client;
        return channel;

      case ChannelType.Dm:
        final users = [];
        for (int i = 0; i < obj["recipients"].length; i++)
          users.add(await User.fromMap(obj["recipients"][i], client));
        final channel = new TextChannel("DM", new Snowflake(obj["id"]), channelType, recipients: users)
          ..client = client;
        return channel;

      case ChannelType.GroupDm:
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

class VoiceChannel extends DiscordObject implements Channel {
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