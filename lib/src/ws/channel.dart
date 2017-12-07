import "dart:async";
import "../internals.dart";
import "../client.dart";
import "../enums.dart";
import "guild.dart";
import "message.dart";
import "user.dart";
import "embed.dart";

abstract class Channel extends DiscordObject {
  /// Name of the channel.
  String name;

  int id;

  static Future<Channel> fromDynamic(dynamic obj, DiscordClient client) async {
    int type = obj["type"];
    if (type == 2)
      return VoiceChannel.fromDynamic(obj, client);
    else
      return TextChannel.fromDynamic(obj, client);
  }
}

class TextChannel extends DiscordObject implements Channel {
  String name;
  int id;

  /// Guild of the channel, if any. Refer to [type] property and check for [GuildText].
  Guild guild;

  /// The recipient of this DM, if any. Refer to [type] property and check for [Dm].
  User get recipient => type == ChannelType.Dm ? recipients.first : null;

  /// A list of recipients of this group DM, if any. Refer to [type] property and check for [GroupDm] or [Dm].
  List<User> recipients;

  /// Type of the channel.
  ChannelType type;

  /// Send a message to the channel.
  Future<Message> sendMessage(String content, {Embed embed}) async => await client.sendMessage(content, this, embed: embed);

  TextChannel(this.name, this.id, this.type, {this.guild, this.recipients});

  static Map<int, ChannelType> ChannelTypes = {
    0: ChannelType.GuildText,
    1: ChannelType.Dm,
    2: ChannelType.GuildVoice,
    3: ChannelType.GroupDm,
    4: ChannelType.GuildCategory
  };

  static Future<TextChannel> fromDynamic(dynamic obj, DiscordClient client, {Guild guild}) async {
    final channelType = ChannelTypes[obj["type"]];
    switch (channelType) {
      case ChannelType.GuildText:
        final channel = new TextChannel(obj["name"], obj["id"], channelType,
          guild: guild != null ? guild : (obj["guild_id"] != null ? client.getGuild(obj["guild_id"]) : null))
          ..client = client;
        return channel;

      case ChannelType.Dm:
        final users = [];
        for (int i = 0; i < obj["recipients"].length; i++)
          users.add(await User.fromDynamic(obj["recipients"][i], client));
        final channel = new TextChannel("DM", obj["id"], channelType,
          recipients: users)
          ..client = client;
        return channel;

      case ChannelType.GroupDm:
        final users = [];
        for (int i = 0; i < obj["recipients"].length; i++)
          users.add(await User.fromDynamic(obj["recipients"][i], client));
        final channel = new TextChannel("GroupDM", obj["id"], channelType,
          recipients: users)
          ..client = client;
        return channel;

      default:
        return null;
    }
  }
}

class VoiceChannel extends DiscordObject implements Channel {
  String name;
  int id;

  Guild guild;

  VoiceChannel(this.name, this.id);

  static Future<VoiceChannel> fromDynamic(dynamic obj, DiscordClient client, {Guild guild}) async {
    return null;
  }
}