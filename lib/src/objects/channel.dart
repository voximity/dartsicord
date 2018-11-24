part of '../../dartsicord.dart';

/// A Channel resource. Could potentially be any of [ChannelType].
abstract class Channel extends _Resource {
  _Route get _endpoint => client.api + "channels" + id;

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

  static Future<T> _fromMap<T extends Channel>(
      Map<String, dynamic> obj, DiscordClient client) {
    final type = obj["type"];
    if (type == 2)
      return VoiceChannel._fromMap(obj, client) as Future<T>;
    else
      return TextChannel._fromMap(obj, client) as Future<T>;
  }
}

/// A Text Channel resource. Could be any of [ChannelType] suffixed with `Text`.
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
  List<User> recipients = [];

  /// A list of [Webhook] objects, if any. Refer to the [type] property and check for [ChannelType.guildText].
  List<Webhook> webhooks = [];

  /// A list of [Overwrite] objects, if any. Refer to the [type] property and check for [ChannelType.guildText].
  List<Overwrite> overwrites = [];

  /// Deletes this channel.
  Future<void> delete() => _endpoint.delete();

  /// Modifies this channel using the given positional parameters [name], [position], [topic], [newOverwrites], and [nsfw].
  Future<Null> modify(
      {String name,
      int position,
      String topic,
      List<Overwrite> newOverwrites,
      bool nsfw}) async {
    final query = {
      "name": name,
      "position": position,
      "topic": topic,
      "nsfw": nsfw,
      "permission_overwrites": newOverwrites.map((o) => o._toMap())
    };

    final response = await _endpoint.patch(query);
    final map = json.decode(response.body);

    this.name = map["name"] as String;
    this.position = map["position"] as int;
    this.topic = map["topic"] as String;
    this.nsfw = map["nsfw"] as bool;
    final permissionOverwrites =
        (map["permission_overwrites"] as List).cast<Map<String, dynamic>>();
    overwrites = permissionOverwrites.map(Overwrite._fromMap).toList();
  }

  /// Creates a [Webhook] for this channel named [name] using the given positional parameter [avatar].
  Future<Webhook> createWebhook(String name, {String avatar}) async {
    final query = {"name": name, "avatar": avatar};

    final route = _endpoint + "webhooks";
    final response = await route.post(query);
    final Map<String, dynamic> data = json.decode(response.body);
    return Webhook._fromMap(data, client);
  }

  /// Modify [existingOverwrite]. If either [newAllow] or [newDeny] are specified, they will completely overwrite
  /// the old allow/deny, so do not rely on this to add new permissions.
  Future<Null> modifyPermission(
      {Overwrite existingOverwrite,
      List<RolePermission> newAllow,
      List<RolePermission> newDeny,
      OverwriteType type}) async {
    final query = {
      "allow": Role._permissionToRaw(newAllow),
      "deny": Role._permissionToRaw(newDeny),
      "type": (new Map.fromIterables(
          Overwrite.internalMap.values, Overwrite.internalMap.keys))[type]
    };
    await (_endpoint + "permissions" + existingOverwrite.targetId).put(query);
  }

  /// Fire a typing request to this channel.
  Future<void> startTyping() => (_endpoint + "typing").post({});

  /// Gets a [List] of [Invite] objects that this channel possesses.
  Future<List<Invite>> getInvites() async {
    final response = await (_endpoint + "invites").get();
    return Future.wait((json.decode(response.body) as List)
        .map((i) => Invite._fromMap(i as Map<String, dynamic>, client)));
  }

  /// Creates a new [Invite] for this channel using the given positional parameters [maxAge], [maxUses], [temporary], and [unique].
  Future<Invite> createInvite(
      {Duration maxAge,
      int maxUses = 0,
      bool temporary = false,
      bool unique = false}) async {
    maxAge ??= const Duration(hours: 24);

    final query = {
      "max_age": maxAge.inSeconds,
      "max_uses": maxUses,
      "temporary": temporary,
      "unique": unique
    };

    final response = await (_endpoint + "invites").post(query);
    final Map<String, dynamic> data = json.decode(response.body);
    return Invite._fromMap(data, client);
  }

  /// Gets a [List] of [Message] objects that represent the pins in this channel.
  Future<List<Message>> getPins() async {
    final response = await (_endpoint + "pins").get();
    final data =
        (json.decode(response.body) as List).cast<Map<String, dynamic>>();
    return Future.wait(data.map((m) => Message._fromMap(m, client)));
  }

  /// Gets a [List] of [Message] objects given the [limit].
  ///
  /// Optionally, you can specify [downloadType] which is a [MessageDownloadType]
  /// to specify where messages should be searched. To use this feature, the
  /// positional parameter [base] must be given.
  Future<List<Message>> getMessages(
      {int limit = 50,
      MessageDownloadType downloadType = MessageDownloadType.after,
      Message base}) async {
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

    final route = _endpoint + "messages"
      ..url += query;
    final response = await route.get();
    final data =
        (json.decode(response.body) as List).cast<Map<String, dynamic>>();
    return Future.wait(data.map((m) => Message._fromMap(m, client)));
  }

  /// Gets a [Message] object given the [id].
  Future<Message> getMessage(dynamic id) async {
    final response = await (_endpoint + "messages" + id).get();
    return await Message._fromMap(
        json.decode(response.body) as Map<String, dynamic>, client);
  }

  /// Bulk-deletes a [List] of [Message] objects from this channel.
  ///
  /// 2-100 messages may be specified. Messages older than 2 weeks are unaffected.
  Future<Null> bulkDeleteMessages(List<Message> messages) async {
    final query = {"messages": messages.map((m) => m.id.id).toList()};
    await (_endpoint + "messages" + "bulk-delete").post(query);
  }

  /// Send a message to this channel.
  ///
  /// [content] is required. If you wish to send an [Embed], you must leave it blank ("").
  /// If you want to specify an [Embed], you first need to build an embed using the [Embed] object.
  /// Documentation for embed building is within the [Embed] object.
  Future<Message> sendMessage(String content, {Embed embed}) async {
    final query = {"content": content, "embed": embed?._toMap()};
    final response = await (_endpoint + "messages").post(query);
    final Map<String, dynamic> parsed = json.decode(response.body);
    return (await Message._fromMap(parsed, client))..author = client.user;
  }

  TextChannel._raw(this.name, this.id, this.type,
      {this.guild, this.recipients});

  static Future<TextChannel> _fromMap(
      Map<String, dynamic> obj, DiscordClient client,
      {Guild guild}) async {
    final channelType = Channel.types[obj["type"]];
    switch (channelType) {
      case ChannelType.guildText:
        final channel = new TextChannel._raw(
            obj["name"] as String, new Snowflake(obj["id"]), channelType,
            guild: guild != null
                ? guild
                : (obj["guild_id"] != null
                    ? client.getGuild(obj["guild_id"])
                    : null))
          ..client = client;
        final permissionOverwrites =
            (obj["permission_overwrites"] as List).cast<Map<String, dynamic>>();
        for (int i = 0; i < permissionOverwrites.length; i++)
          channel.overwrites.add(Overwrite._fromMap(permissionOverwrites[i]));
        return channel;

      case ChannelType.dm:
        final users = <User>[];
        final recipients =
            (obj["recipients"] as List).cast<Map<String, dynamic>>();
        for (int i = 0; i < recipients.length; i++)
          users.add(await User._fromMap(recipients[i], client));
        final channel = new TextChannel._raw(
            "DM", new Snowflake(obj["id"]), channelType,
            recipients: users)
          ..client = client;
        return channel;

      case ChannelType.groupDm:
        final users = <User>[];
        final recipients =
            (obj["recipients"] as List).cast<Map<String, dynamic>>();
        for (int i = 0; i < recipients.length; i++)
          users.add(await User._fromMap(recipients[i], client));
        final channel = new TextChannel._raw(
            "GroupDM", new Snowflake(obj["id"]), channelType,
            recipients: users)
          ..client = client;
        return channel;

      default:
        return null;
    }
  }
}

/// Rather unfinished class
class VoiceChannel extends Channel {
  String name;
  Guild guild;

  _Route get _endpoint => client.api + "channels" + id;

  ChannelType type;

  Snowflake id;

  VoiceChannel(this.name, this.id);

  static Future<VoiceChannel> _fromMap(
          Map<String, dynamic> obj, DiscordClient client,
          {Guild guild}) =>
      null;
}
