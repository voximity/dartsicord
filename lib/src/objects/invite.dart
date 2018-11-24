part of '../../dartsicord.dart';

/// An Invite object. Create with [TextChannel.createInvite].
class Invite {
  _Route get _endpoint => client.api + "invites" + code;

  /// The code of the invite.
  String code;

  /// The guild of the invite. This object is likely partial; it may need to be `download` ed.
  Guild guild;

  /// The channel of the invite. This object is likely partial; it may need to be `download` ed.
  TextChannel channel;

  /// The total number of uses on this invite.
  int uses;

  /// The maximum number of uses on this invite.
  int maxUses;

  /// Whether or not this invite only grants temporary access.
  bool temporary;

  /// Whether or not this invite is revoked.
  bool revoked;

  /// The time at which this invite was created.
  DateTime createdAt;

  /// The maximum duration at which this invite can be used.
  Duration maxAge;

  /// The [User] object who created this invite.
  User inviter;

  /// The client associated with the invite.
  DiscordClient
      client; // It's not an actual Resource, so I can't implement the class...

  Invite._raw(this.code,
      {this.guild,
      this.channel,
      this.uses,
      this.maxUses,
      this.temporary,
      this.revoked,
      this.createdAt,
      this.maxAge,
      this.inviter});

  Future<void> accept() => _endpoint.post({});

  Future<void> delete() => _endpoint.delete();

  static Future<Invite> _fromMap(
      Map<String, dynamic> obj, DiscordClient client) async {
    final inv = new Invite._raw(obj["code"] as String,
        guild: client.getGuild(obj["guild"]["id"]),
        channel: await client.getTextChannel(obj["channel"]["id"]));

    final Map<String, dynamic> inviterData = obj["inviter"];
    if (inviterData != null) {
      // Includes metadata.
      inv
        ..inviter = await User._fromMap(inviterData, client)
        ..uses = obj["uses"] as int
        ..maxUses = obj["max_uses"] as int
        ..maxAge = new Duration(seconds: obj["max_age"] as int)
        ..temporary = obj["temporary"] as bool
        ..createdAt = DateTime.parse(obj["created_at"] as String)
        ..revoked = obj["revoked"] as bool;
    }

    return inv;
  }
}
