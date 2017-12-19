import "../internals.dart";
import "../client.dart";
import "../object.dart";

import "channel.dart";
import "user.dart";
import "permission.dart";
import "emoji.dart";

import "dart:async";
import "dart:convert";

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
    final roleList = [];
    roles.forEach((r) => roleList.add(r));

    final route = localEndpoint + "emojis" + emoji.id;
    await route.patch({"name": name, "roles": roleList}, client: client);
  }

  Future deleteEmoji(Emoji emoji) async {
    final route = localEndpoint + "emojis" + emoji.id;
    await route.delete(client: client);
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
          final role = Role.fromMap(obj["roles"][i], client);
          role.guild = this;
          roles.add(role);
        }
      }
  }

  static Future<Guild> fromMap(Map<String, dynamic> obj, DiscordClient client) async {
    if (obj["unavailable"] == null || obj["unavailable"] == false) {
      final g = new Guild(obj["name"], new Snowflake(obj["id"]));
      g.client = client;

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
          final role = Role.fromMap(obj["roles"][i], client);
          role.guild = g;
          g.roles.add(role);
        }
      }
      return g;
    } else { // This is a partial guild. A lot of features will be missing and must be [download]'ed.
      return new Guild(null, new Snowflake(obj["id"]), partial: true);
    }
  }
}

class Role extends DiscordObject {
  Snowflake id;

  /// The guild that this role is in.
  Guild guild;

  /// The name of the role.
  String name;

  /// The color of the role. Can be set using hexadecimal, e.g. 0x00AAFF.
  int color;

  /// Whether or not the role is hoisted, meaning it appears separately in the user list.
  bool hoisted;

  /// The position of the role in the role list.
  int position;

  /// The raw permissions of the role.
  int permissionsRaw;

  /// A list of [Permission] objects generated from the [permissionsRaw] variable.
  List<Permission> get permissions => Permission.fromRaw(permissionsRaw, Permission.RolePermissions);

  /// Whether or not this role is created and managed by a bot user.
  bool managed;

  /// Whether or not this role is mentionable.
  bool mentionable;

  Role(this.name, this.id, {this.color, this.hoisted, this.position, this.permissionsRaw, this.managed, this.mentionable, this.guild});

  static Role fromMap(Map<String, dynamic> obj, DiscordClient client) {
    return new Role(
      obj["name"], new Snowflake(obj["id"]),
      hoisted: obj["hoist"],
      position: obj["position"],
      permissionsRaw: obj["permissions"],
      managed: obj["managed"],
      mentionable: obj["mentionable"]
    )..client = client;
  }
}