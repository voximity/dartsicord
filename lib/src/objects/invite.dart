import "dart:async";

import "../client.dart";
import "../networking.dart";
import "channel.dart";
import "guild.dart";
import "user.dart";

class Invite {
  Route get endpoint => client.api + "invites" + code;

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
  DiscordClient client; // It's not an actual Resource, so I can't implement the class...

  Invite(this.code, {this.guild, this.channel,
    this.uses, this.maxUses, this.temporary, this.revoked, this.createdAt, this.maxAge, this.inviter});

  Future<Null> accept() =>
    endpoint.post({});
  
  Future<Null> delete() =>
    endpoint.delete();

  static Future<Invite> fromMap(Map<String, dynamic> obj, DiscordClient client) async {
    final inv = new Invite(obj["code"],
      guild: client.getGuild(obj["guild"]["id"]),
      channel: await client.getTextChannel(obj["channel"]["id"]));

    if (obj["inviter"] != null) { // Includes metadata.
      inv
        ..inviter = await User.fromMap(obj["inviter"], client)
        ..uses = obj["uses"]
        ..maxUses = obj["max_uses"]
        ..maxAge = new Duration(seconds: obj["max_age"])
        ..temporary = obj["temporary"]
        ..createdAt = DateTime.parse(obj["created_at"])
        ..revoked = obj["revoked"];
    }

    return inv;
  }
}