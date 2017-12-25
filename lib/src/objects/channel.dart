import "dart:async";
import "dart:convert";

import "../client.dart";
import "../enums.dart";
import "../networking.dart";
import "../object.dart";

import "embed.dart";
import "guild.dart";
import "invite.dart";
import "message.dart";
import "overwrite.dart";
import "role.dart";
import "user.dart";
import "webhook.dart";

abstract class Channel extends Resource {
  Route get endpoint => client.api + "channels" + id;
  
  /// Name of the channel.
  String name;

  /// Guild of the channel, if any.
  Guild guild;

  /// The type of the channel.
  ChannelType type;

  /// Whether or not this object is considered a partial channel object.
  bool get partial => name == null;

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

  /// Guild of the channel, if any. Refer to the [type] property and check for [ChannelType.guildText].
  Guild guild;
  
  /// Position of the channel. Refer to the [type] property and check for [ChannelType.guildText].
  int position;

  /// The topic of this channel.
  String topic;

  /// Whether or not this channel should be marked as NSFW.
  bool nsfw;

  /// The recipient of this DM, if any. Refer to [type] property and check for [ChannelType.dm].
  User get recipient => type == ChannelType.dm ? recipients.first : null;

  /// A list of recipients of this group DM, if any. Refer to [type] property and check for [ChannelType.groupDm] or [ChannelType.dm].
  List<User> recipients;

  /// A list of [Webhook] objects, if any. Refer to the [type] property and check for [ChannelType.guildText].
  List<Webhook> webhooks;

  /// A list of [Overwrite] objects, if any. Refer to the [type] property and check for [ChannelType.guildText].
  List<Overwrite> overwrites;

  /// Deletes this channel.
  Future<Null> delete() =>
    endpoint.delete();

  /// Modifies this channel using the given positional parameters [name], [position], [topic], [newOverwrites], and [nsfw].
  Future<Null> modify({String name, int position, String topic, List<Overwrite> newOverwrites, bool nsfw}) async {
    final query = {
      "name": name,
      "position": position,
      "topic": topic,
      "nsfw": nsfw,
      "permission_overwrites": newOverwrites.map((o) => o.toMap())
    };
    
    final response = await endpoint.patch(query);
    final map = JSON.decode(response.body);

    this.name = map["name"];
    this.position = map["position"];
    this.topic = map["topic"];
    this.nsfw = map["nsfw"];
    overwrites = map["permission_overwrites"].map(Overwrite.fromMap);
  }

  /// Creates a [Webhook] for this channel named [name] using the given positional parameter [avatar].
  Future<Webhook> createWebhook(String name, {String avatar}) async {
    final query = {
      "name": name,
      "avatar": avatar
    };

    final route = endpoint + "webhooks";
    final response = await route.post(query);
    return Webhook.fromMap(JSON.decode(response.body), client);
  }

  /// Modify [existingOverwrite]. If either [newAllow] or [newDeny] are specified, they will completely overwrite
  /// the old allow/deny, so do not rely on this to add new permissions.
  Future<Null> modifyPermission({Overwrite existingOverwrite, List<RolePermission> newAllow, List<RolePermission> newDeny, OverwriteType type}) async {
    final query = {
      "allow": Role.permissionToRaw(newAllow),
      "deny": Role.permissionToRaw(newDeny),
      "type": (new Map.fromIterables(Overwrite.internalMap.values, Overwrite.internalMap.keys))[type]
    };
    await (endpoint + "permissions" + existingOverwrite.targetId).put(query);
  }

  /// Fire a typing request to this channel.
  Future<Null> startTyping() =>
    (endpoint + "typing").post({});

  /// Gets a [List] of [Invite] objects that this channel possesses.
  Future<List<Invite>> getInvites() async {
    final response = await (endpoint + "invites").get();
    return JSON.decode(response.body).map((i) => Invite.fromMap(i, client));
  }

  /// Creates a new [Invite] for this channel using the given positional parameters [maxAge], [maxUses], [temporary], and [unique].
  Future<Invite> createInvite({Duration maxAge, int maxUses = 0, bool temporary = false, bool unique = false}) async {
    maxAge ??= const Duration(hours: 24);

    final query = {
      "max_age": maxAge.inSeconds,
      "max_uses": maxUses,
      "temporary": temporary,
      "unique": unique
    };

    final response = await (endpoint + "invites").post(query);
    return Invite.fromMap(JSON.decode(response.body), client);
  }

  /// Gets a [List] of [Message] objects that represent the pins in this channel.
  Future<List<Message>> getPins() async {
    final response = await (endpoint + "pins").get();
    return Future.wait(JSON.decode(response.body).map((m) async => await Message.fromMap(m, client)));
  }

  /// Gets a [List] of [Message] objects given the [limit].
  /// 
  /// Optionally, you can specify [downloadType] which is a [MessageDownloadType]
  /// to specify where messages should be searched. To use this feature, the
  /// positional parameter [base] must be given.
  Future<List<Message>> getMessages({int limit = 50, MessageDownloadType downloadType = MessageDownloadType.after, Message base}) async {
    var query = "?limit=$limit";

    if (base != null) {
      final id = base.id.toString();
      switch (downloadType) {
        case MessageDownloadType.after:
          query += "&after=$id";
          break;
        case MessageDownloadType.before:
          query += "&before=$id";
          break;
        case MessageDownloadType.around:
          query += "&around=$id";
          break;
      }
    }
    
    final route = endpoint + "messages"
     ..url += query;
    final response = await route.get();
    return Future.wait(JSON.decode(response.body).map((m) async => await Message.fromMap(m, client)));
  }

  /// Gets a [Message] object given the [id].
  Future<Message> getMessage(dynamic id) async {
    final response = await (endpoint + "messages" + id).get();
    return await Message.fromMap(JSON.decode(response.body), client);
  }

  /// Bulk-deletes a [List] of [Message] objects from this channel.
  /// 
  /// 2-100 messages may be specified. Messages older than 2 weeks are unaffected.
  Future<Null> bulkDeleteMessages(List<Message> messages) async {
    final query = messages.map((m) => m.id.id);
    await (endpoint + "messages" + "bulk-delete").post(query);
  }

  /// Send a message to this channel.
  /// 
  /// [content] is required. If you wish to send an [Embed], you must leave it blank ("").
  /// If you want to specify an [Embed], you first need to build an embed using the [Embed] object.
  /// Documentation for embed building is within the [Embed] object.
  Future<Message> sendMessage(String content, {Embed embed}) async {
    final query = {
      "content": content,
      "embed": embed?.toMap()
    };
    final response = await (endpoint + "messages").post(query);
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
          ..overwrites = obj["permission_overwrites"]?.map((o) => Overwrite.fromMap(o, client))
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

  Route get endpoint => client.api + "channels" + id;

  ChannelType type;

  Snowflake id;

  VoiceChannel(this.name, this.id);

  static Future<VoiceChannel> fromMap(Map<String, dynamic> obj, DiscordClient client, {Guild guild}) =>
    null;
}