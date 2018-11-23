part of '../../dartsicord.dart';

/// A Guild resource. Contains information on what is known as a Server through Discord.
class Guild extends _Resource {
  _Route get _endpoint => client.api + "guilds" + id;

  /// Name of guild.
  String name;

  Snowflake id;

  /// Whether or not this guild class is partial.
  bool partial;

  /// A list of [Channel] objects that the guild has.
  List<Channel> channels = [];

  /// A list of [TextChannel] objects, derived from the [channels] property.
  List<TextChannel> get textChannels =>
      channels.whereType<TextChannel>().toList();

  /// A list of [Role] objects that the guild has.
  List<Role> roles = [];

  /// A list of [Emoji] objects that the guild has.
  List<Emoji> emojis = [];

  /// A list of [Webhook] objects that the guild has.
  List<Webhook> get webhooks =>
      textChannels.fold([], (p, c) => p..addAll(c.webhooks));

  /// Leave this guild.
  Future<void> leave() =>
      (client.api + "users" + "@me" + "guilds" + id).delete();

  /// Retrieves a Member object from a User object.
  Future<Member> getMember(User user) async {
    final response = await (_endpoint + "members" + user.id).get();
    final Map<String, dynamic> data = json.decode(response.body);
    return Member._fromMap(data, client, this);
  }

  /// Kick a member from this guild.
  Future<void> kickMember(Member member) =>
      (_endpoint + "members" + member.id).delete();

  /// Ban a member from this guild.
  Future<void> banMember(Member member, {int deleteMessageDays}) =>
      (_endpoint + "bans" + member.id)
          .put({"delete-message-days": deleteMessageDays});

  /// Ban a user's ID from this guild.
  Future<void> banId(int userId) => (_endpoint + "bans" + userId).put({});

  /// Creates a role for this guild using the given positional parameters [name], [permissions], [color], [hoisted], and [mentionable].
  Future<Role> createRole(
      {String name = "new role",
      List<RolePermission> permissions,
      int color = 0,
      bool hoisted = false,
      bool mentionable = false}) async {
    permissions ??= [];

    final query = {
      "name": name,
      "permissions": Role._permissionToRaw(permissions),
      "color": color,
      "hoist": hoisted,
      "mentionable": mentionable
    };

    final response = await (_endpoint + "roles").post(query);
    final Map<String, dynamic> data = json.decode(response.body);
    return Role._fromMap(data, client);
  }

  /// Give a member a role.
  Future<void> addMemberRole(Member member, Role role) =>
      (_endpoint + "members" + member.id + "roles" + role.id).put({});

  /// Remove a role from a member.
  Future<void> removeMemberRole(Member member, Role role) =>
      (_endpoint + "members" + member.id + "roles" + role.id).delete();

  /// Modify an existing emoji.
  Future<void> modifyEmoji(Emoji emoji, {String name, List<Role> roles}) =>
      (_endpoint + "emojis" + emoji.id).patch({"name": name, "roles": roles});

  /// Delete an existing emoji.
  Future<void> deleteEmoji(Emoji emoji) =>
      (_endpoint + "emojis" + emoji.id).delete();

  /// Creates a webhook. See [TextChannel.createWebhook] for further documentation.
  Future<Webhook> createWebhook(TextChannel channel, String name,
          {String avatar}) =>
      channel.createWebhook(name, avatar: avatar);

  //
  // Constructors
  //

  Guild._raw(this.name, this.id, {this.partial});

  Future<Null> download() async {
    if (!partial) return;

    final response = await _endpoint.get();

    final obj = json.decode(response.body);
    final channelsData = (obj["channels"] as List).cast<Map<String, dynamic>>();
    if (channelsData != null) {
      for (int i = 0; i < channelsData.length; i++) {
        if (channelsData[i]["type"] != 0) continue;
        final channel =
            await TextChannel._fromMap(channelsData[i], client, guild: this);
        channels.add(channel);
      }
    }
    final rolesData = (obj["roles"] as List).cast<Map<String, dynamic>>();
    if (rolesData != null) {
      for (int i = 0; i < rolesData.length; i++) {
        final role = Role._fromMap(rolesData[i], client)..guild = this;
        roles.add(role);
      }
    }
  }

  static Future<Guild> _fromMap(
      Map<String, dynamic> obj, DiscordClient client) async {
    if (obj["unavailable"] == null || obj["unavailable"] == false) {
      final g = new Guild._raw(obj["name"] as String, new Snowflake(obj["id"]))
        ..client = client;

      final emojisData = (obj["emojis"] as List).cast<Map<String, dynamic>>();
      if (emojisData != null) {
        for (int i = 0; i < emojisData.length; i++) {
          final emoji = await Emoji._fromMap(emojisData[i], client, guild: g);
          g.emojis.add(emoji);
        }
      }
      final channelsData =
          (obj["channels"] as List).cast<Map<String, dynamic>>();
      if (channelsData != null) {
        for (int i = 0; i < channelsData.length; i++) {
          if (channelsData[i]["type"] != 0) continue;
          final channel =
              await TextChannel._fromMap(channelsData[i], client, guild: g);
          g.channels.add(channel);
        }
      }
      final rolesData = (obj["roles"] as List).cast<Map<String, dynamic>>();
      if (rolesData != null) {
        for (int i = 0; i < rolesData.length; i++) {
          final role = Role._fromMap(rolesData[i], client)..guild = g;
          g.roles.add(role);
        }
      }
      return g;
    } else {
      // This is a partial guild. A lot of features will be missing and must be [download]'ed.
      return new Guild._raw(null, new Snowflake(obj["id"]), partial: true);
    }
  }
}
