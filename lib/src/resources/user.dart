import "dart:async";
import "dart:convert";

import "../client.dart";
import "../internals.dart";
import "../object.dart";

import "channel.dart";
import "guild.dart";
import "role.dart";

class User extends DiscordObject {
  static Route endpoint = new Route() + "users";

  /// Username of the user.
  String username;

  /// Discriminator of the user.
  String discriminator;

  Snowflake id;

  /// Creates a direct message channel with this user.
  Future<TextChannel> createDirectMessage() async {
    final route = User.endpoint + "@me" + "channels";
    final response = await route.post({
      "recipient_id": id
    }, client: client);
    final channel = TextChannel.fromMap(JSON.decode(response.body), client);
    return channel;
  }

  User(this.username, this.discriminator, this.id);

  static Future<User> fromMap(Map<String, dynamic> obj, DiscordClient client) async =>
    new User(obj["username"], obj["discriminator"], new Snowflake(obj["id"]))..client = client;
}

class Member extends DiscordObject {
  Snowflake id;

  /// The guild that this Member is in.
  Guild guild;

  /// The user representing this member.
  User user;

  /// The nickname of the member.
  String nickname;

  /// A list of Role objects that the user possesses in the guild.
  List<Role> roles;

  /// Whether or not the user is deafened by the guild.
  bool deafened;

  /// Whether or not the user is muted by the guild.
  bool muted;

  /// Kicks this member from the parent guild.
  Future kick() => guild.kickMember(this);

  /// Bans this member from the parent guild.
  Future ban({int deleteMessagesCount}) =>
    guild.banMember(this, deleteMessagesCount: deleteMessagesCount);
  
  /// Adds a role to this member.
  Future addRole(Role role) =>
    guild.addMemberRole(this, role);

  /// Removes a role from this member.
  Future removeRole(Role role) =>
    guild.removeMemberRole(this, role);

  Member(this.user, this.guild, {this.nickname, this.roles, this.deafened, this.muted});

  static Future<Member> fromMap(Map<String, dynamic> obj, DiscordClient client, Guild guild) async {
    final roleList = [];
    for (int i = 0; i < obj["roles"].length; i++) {
      final roleId = obj["roles"][i];
      final role = guild.roles.firstWhere((r) => r.id.toString() == roleId.toString());
      roleList.add(role);
    }
    return new Member(await User.fromMap(obj["user"], client), guild,
      roles: roleList,
      nickname: obj["nick"],
      deafened: obj["deaf"],
      muted: obj["mute"])..client = client;
  }
}