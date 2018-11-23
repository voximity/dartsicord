part of '../../dartsicord.dart';

/// An Emoji resource. Can correspond to a guild or be a global emoji.
class Emoji extends _Resource {
  Snowflake id;

  /// The guild this emoji was created in.
  Guild guild;

  /// Whether or not this emoji requires colons to type.
  bool requiresColons;

  /// Whether or not this emoji is managed.
  bool managed;

  /// The name of this emoji. If this is a standard emoji, a unicode-based emoji can be passed as well.
  String name;

  /// The roles that this emoji is whitelisted to.
  List<Role> roles = [];

  /// The user that created this emoji.
  User author;

  Emoji(this.name,
      {this.id,
      this.guild,
      this.roles,
      this.author,
      this.requiresColons,
      this.managed});

  String toString() => id == null ? name : id.toString();

  static Future<Emoji> _fromMap(Map<String, dynamic> obj, DiscordClient client,
      {Guild guild}) async {
    final emoji = new Emoji(obj["name"] as String,
        id: new Snowflake(obj["id"]),
        guild: guild,
        author: obj["user"] != null
            ? await User._fromMap(obj["user"] as Map<String, dynamic>, client)
            : null,
        requiresColons: obj["requires_colons"] as bool,
        managed: obj["managed"] as bool)
      ..client = client;

    if (obj.containsKey("roles")) {
      final roles = (obj["roles"] as List).cast<Map<String, dynamic>>();
      for (int i = 0; i < roles.length; i++) {
        final role = await Role._fromMap(roles[i], client)
          ..guild = guild;
        emoji.roles.add(role);
      }
    }

    return emoji;
  }
}
