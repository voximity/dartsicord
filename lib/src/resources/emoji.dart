import "dart:async";
import "../client.dart";
import "../object.dart";
import "guild.dart";
import "role.dart";
import "user.dart";

class Emoji extends DiscordObject {
  Snowflake id;

  /// The guild this emoji was created in.
  Guild guild;

  /// Whether or not this emoji requires colons to type.
  bool requiresColons;
  
  /// Whether or not this emoji is managed.
  bool managed;

  /// The name of this emoji.
  String name;

  /// The roles that this emoji is whitelisted to.
  List<Role> roles = [];

  /// The user that created this emoji.
  User author;

  Emoji(this.name, this.id, {this.guild, this.roles, this.author, this.requiresColons, this.managed});

  static Future<Emoji> fromMap(Map<String, dynamic> obj, DiscordClient client, {Guild guild}) async {
    final emoji = new Emoji(obj["name"], new Snowflake(obj["id"]),
      guild: guild,
      author: obj["user"] != null ? await User.fromMap(obj["user"], client) : null,
      requiresColons: obj["requires_colons"],
      managed: obj["managed"])
      ..client = client;
    
    if (obj["roles"]) {
      for (int i = 0; i < obj["roles"].length; i++) {
        final role = await Role.fromMap(obj["roles"][i], client)
          ..guild = guild;
        emoji.roles.add(role);
      }
    }

    return emoji;
  }
}