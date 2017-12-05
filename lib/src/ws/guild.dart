import "../internals.dart";
import "../client.dart";

import "channel.dart";
import "user.dart";
import "permission.dart";

import "dart:async";
import "dart:convert";

class Guild extends DiscordObject {
  /// Name of guild.
  String name;

  int id;

  /// A list of [Channel] objects that the guild has.
  List<Channel> channels = [];

  /// A list of [TextChannel] objects, derived from the [channels] property.
  List<TextChannel> get textChannels => channels.where((c) => c is TextChannel);

  /// A list of [Role] objects that the guild has.
  List<Role> roles = [];

  /// Retrieves a Member object from a User object.
  Future<Member> getMember(User user) async {
    final route = new Route(client) + "guilds" + id.toString() + "members" + user.id.toString();
    final response = await route.get();
    return Member.fromDynamic(JSON.decode(response.body), client, this);
  }

  Guild(this.name, this.id);

  static Guild fromDynamic(dynamic obj, DiscordClient client) {
    final g = new Guild(obj["name"], obj["id"]);
    g.client = client;

    if (obj["channels"] != null) {
      for(int i = 0; i < obj["channels"].length; i++) {
        if (obj["channels"][i]["type"] != 0)
          continue;
        final channel = TextChannel.fromDynamic(obj["channels"][i], client, guild: g);
        g.channels.add(channel);
      }
    }
    if (obj["roles"] != null) {
      for(int i = 0; i < obj["roles"].length; i++) {
        final role = Role.fromDynamic(obj["roles"][i], client);
        role.guild = g;
        g.roles.add(role);
      }
    }

    return g;
  }
}

class Role extends DiscordObject {
  int id;

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

  static Role fromDynamic(dynamic obj, DiscordClient client) {
    return new Role(
      obj["name"], obj["id"],
      hoisted: obj["hoist"],
      position: obj["position"],
      permissionsRaw: obj["permissions"],
      managed: obj["managed"],
      mentionable: obj["mentionable"]
    )..client = client;
  }
}