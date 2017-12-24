import "../client.dart";
import "../object.dart";

import "guild.dart";
import "permission.dart";

class Role extends Resource {
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
  List<Permission> get permissions => Permission.fromRaw(permissionsRaw, Permission.rolePermissions);

  /// Whether or not this role is created and managed by a bot user.
  bool managed;

  /// Whether or not this role is mentionable.
  bool mentionable;

  Role(this.name, this.id, {this.color, this.hoisted, this.position, this.permissionsRaw, this.managed, this.mentionable, this.guild});

  static Role fromMap(Map<String, dynamic> obj, DiscordClient client) => 
    new Role(
      obj["name"], new Snowflake(obj["id"]),
      hoisted: obj["hoist"],
      position: obj["position"],
      permissionsRaw: obj["permissions"],
      managed: obj["managed"],
      mentionable: obj["mentionable"]
    )..client = client;
}