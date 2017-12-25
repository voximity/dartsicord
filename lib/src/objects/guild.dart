import "dart:async";
import "dart:convert";

import "../client.dart";
import "../enums.dart";
import "../networking.dart";
import "../object.dart";

import "channel.dart";
import "emoji.dart";
import "role.dart";
import "user.dart";
import "webhook.dart";

class Guild extends Resource {
  Route get endpoint => client.api + "guilds" + id;

  /// Name of guild.
  String name;

  Snowflake id;

  /// Whether or not this guild class is partial.
  bool partial;

  /// A list of [Channel] objects that the guild has.
  List<Channel> channels = [];

  /// A list of [TextChannel] objects, derived from the [channels] property.
  List<TextChannel> get textChannels => channels.where((c) => c is TextChannel);

  /// A list of [Role] objects that the guild has.
  List<Role> roles = [];

  /// A list of [Emoji] objects that the guild has.
  List<Emoji> emojis = [];

  /// A list of [Webhook] objects that the guild has.
  List<Webhook> get webhooks => textChannels.fold([], (p, c) => p..addAll(c.webhooks));

  /// Leave this guild.
  Future<Null> leave() =>
    (client.api + "users" + "@me" + "guilds" + id).delete();

  /// Retrieves a Member object from a User object.
  Future<Member> getMember(User user) async {
    final response = await (endpoint + "members" + user.id).get();
    return Member.fromMap(JSON.decode(response.body), client, this);
  }

  /// Kick a member from this guild.
  Future<Null> kickMember(Member member) =>
    (endpoint + "members" + member.id).delete();

  /// Ban a member from this guild.
  Future<Null> banMember(Member member, {int deleteMessageDays}) =>
    (endpoint + "bans" + member.id).put({"delete-message-days": deleteMessageDays});

  /// Ban a user's ID from this guild.
  Future<Null> banId(int userId) =>
    (endpoint + "bans" + userId).put({});

  /// Creates a role for this guild using the given positional parameters [name], [permissions], [color], [hoisted], and [mentionable].
  Future<Role> createRole({
    String name = "new role",
    List<RolePermission> permissions,
    int color = 0,
    bool hoisted = false,
    bool mentionable = false
  }) async {
    permissions ??= [];

    final query = {
      "name": name,
      "permissions": Role.permissionToRaw(permissions),
      "color": color,
      "hoist": hoisted,
      "mentionable": mentionable
    };

    final response = await (endpoint + "roles").post(query);
    return Role.fromMap(JSON.decode(response.body), client);
  }

  /// Give a member a role.
  Future<Null> addMemberRole(Member member, Role role) =>
    (endpoint + "members" + member.id + "roles" + role.id).put({});

  /// Remove a role from a member.
  Future<Null> removeMemberRole(Member member, Role role) =>
    (endpoint + "members" + member.id + "roles" + role.id).delete();

  /// Modify an existing emoji.
  Future<Null> modifyEmoji(Emoji emoji, {String name, List<Role> roles}) =>
    (endpoint + "emojis" + emoji.id).patch({
      "name": name,
      "roles": roles
    });

  /// Delete an existing emoji.
  Future<Null> deleteEmoji(Emoji emoji) =>
    (endpoint + "emojis" + emoji.id).delete();

  /// Creates a webhook. See [TextChannel.createWebhook] for further documentation.
  Future<Webhook> createWebhook(TextChannel channel, String name, {String avatar}) =>
    channel.createWebhook(name, avatar: avatar);

  //
  // Constructors
  //

  Guild(this.name, this.id, {this.partial});

  Future<Null> download() async {
    if (!partial)
      return;

    final response = await endpoint.get();

    final obj = JSON.decode(response.body);
    if (obj["channels"] != null) {
        for(int i = 0; i < obj["channels"].length; i++) {
          if (obj["channels"][i]["type"] != 0)
            continue;
          final channel = await TextChannel.fromMap(obj["channels"][i], client, guild: this);
          channels.add(channel);
        }
      }
      if (obj["roles"] != null) {
        for(int i = 0; i < obj["roles"].length; i++) {
          final role = Role.fromMap(obj["roles"][i], client)
            ..guild = this;
          roles.add(role);
        }
      }
  }

  static Future<Guild> fromMap(Map<String, dynamic> obj, DiscordClient client) async {
    if (obj["unavailable"] == null || obj["unavailable"] == false) {
      final g = new Guild(obj["name"], new Snowflake(obj["id"]))
        ..client = client;

      if (obj["emojis"] != null) {
        for (int i = 0; i < obj["emojis"].length; i++) {
          final emoji = await Emoji.fromMap(obj["emojis"][i], client, guild: g);
          g.emojis.add(emoji);
        }
      }
      if (obj["channels"] != null) {
        for(int i = 0; i < obj["channels"].length; i++) {
          if (obj["channels"][i]["type"] != 0)
            continue;
          final channel = await TextChannel.fromMap(obj["channels"][i], client, guild: g);
          g.channels.add(channel);
        }
      }
      if (obj["roles"] != null) {
        for(int i = 0; i < obj["roles"].length; i++) {
          final role = Role.fromMap(obj["roles"][i], client)
            ..guild = g;
          g.roles.add(role);
        }
      }
      return g;
    } else { // This is a partial guild. A lot of features will be missing and must be [download]'ed.
      return new Guild(null, new Snowflake(obj["id"]), partial: true);
    }
  }
}