import "dart:async";
import "dart:convert";

import "../client.dart";
import "../internals.dart";
import "../object.dart";

import "channel.dart";
import "emoji.dart";
import "permission.dart";
import "role.dart";
import "user.dart";
import "webhook.dart";

class Guild extends DiscordObject {
  static Route endpoint = new Route() + "guilds";
  Route get localEndpoint => Guild.endpoint + id;

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

  /// Leave this guild.
  Future leave() async {
    final route = User.endpoint + "@me" + "guilds" + id;
    await route.delete(client: client);
  }

  /// Retrieves a Member object from a User object.
  Future<Member> getMember(User user) async {
    final route = localEndpoint + "members" + user.id;
    final response = await route.get(client: client);
    return Member.fromMap(JSON.decode(response.body), client, this);
  }

  /// Kick a member from this guild.
  Future kickMember(Member member) async {
    final route = localEndpoint + "members" + member.id;
    await route.delete(client: client);
  }

  /// Ban a member from this guild.
  Future banMember(Member member, {int deleteMessagesCount}) async {
    final route = localEndpoint + "bans" + member.id;
    await route.put({"delete-message-days": deleteMessagesCount}, client: client);
  }

  /// Ban a user's ID from this guild.
  Future banId(int userId) async {
    final route = localEndpoint + "bans" + userId;
    await route.put({}, client: client);
  }

  Future<Role> createRole({
    String name = "new role",
    List<Permission> permissions,
    int color = 0,
    bool hoisted = false,
    bool mentionable = false
  }) async {
    permissions ??= [];

    final query = {
      "name": name,
      "permissions": Permission.toRaw(permissions),
      "color": color,
      "hoist": hoisted,
      "mentionable": mentionable
    };

    final route = localEndpoint + "roles";
    final response = await route.post(query, client: client);
    return Role.fromMap(JSON.decode(response.body), client);

  }

  /// Give a member a role.
  Future addMemberRole(Member member, Role role) async {
    final route = localEndpoint + "members" + member.id + "roles" + role.id;
    await route.put({}, client: client);
  }

  /// Remove a role from a member.
  Future removeMemberRole(Member member, Role role) async {
    final route = localEndpoint + "members" + member.id + "roles" + role.id;
    await route.delete(client: client);
  }

  /// Modify an existing emoji.
  Future modifyEmoji(Emoji emoji, {String name, List<Role> roles}) async {
    final route = localEndpoint + "emojis" + emoji.id;
    await route.patch({"name": name, "roles": roles.map((r) => r)}, client: client);
  }

  /// Delete an existing emoji.
  Future deleteEmoji(Emoji emoji) async {
    final route = localEndpoint + "emojis" + emoji.id;
    await route.delete(client: client);
  }

  Future<Webhook> createWebhook(TextChannel channel, String name, {String avatar}) async {
    final query = {
      "name": name,
      "avatar": avatar
    };

    final route = Channel.endpoint + channel.id + "webhooks";
    final response = await route.post(query, client: client);
    return Webhook.fromMap(JSON.decode(response.body));
  }

  //
  // Constructors
  //

  Guild(this.name, this.id, {this.partial});

  Future download() async {
    if (!partial)
      return;

    final route = endpoint + id;
    final response = await route.get(client: client);

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