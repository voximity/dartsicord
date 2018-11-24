part of '../../dartsicord.dart';

/// A User resource. Not used for guild membership.
class User extends _Resource {
  _Route get _endpoint =>
      client.api + "users" + (id == client.user.id ? "@me" : id);

  /// Username of the user.
  String username;

  /// Discriminator of the user.
  String discriminator;

  /// A pre-made formatted mention for this user.
  String get mention => "<@" + id.toString() + ">";

  /// The ID of the avatar this user has, if any.
  String avatar;

  /// The CDN URL that corresponds to this user's avatar.
  String get avatarUrl => "https://cdn.discordapp.com/avatars/$id/$avatar.png";

  /// Whether or not this user object is partial.
  bool get partial => username == null;

  Snowflake id;

  /// Creates a direct message channel with this user.
  Future<TextChannel> createDirectMessage() async {
    final response = await (_endpoint + "channels").post({"recipient_id": id});
    final channel = TextChannel._fromMap(
        json.decode(response.body) as Map<String, dynamic>, client);
    return channel;
  }

  User(this.username, this.discriminator, this.id, {this.avatar});

  static Future<User> get(dynamic id, DiscordClient client) async {
    final response =
        await (new _Route(client: client) + "users" + id.toString()).get();
    return await _fromMap(
        json.decode(response.body) as Map<String, dynamic>, client);
  }

  static Future<User> _fromMap(
          Map<String, dynamic> obj, DiscordClient client) async =>
      new User(obj["username"] as String, obj["discriminator"] as String,
          new Snowflake(obj["id"]),
          avatar: obj["avatar"] as String)
        ..client = client;
}

/// A Member resource. Modified [User] object that corresponds to a specific guild. Contains information such as [nickname], [roles], etc.
class Member extends _Resource {
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
  Future ban({int deleteMessageDays}) =>
      guild.banMember(this, deleteMessageDays: deleteMessageDays);

  /// Adds a role to this member.
  Future addRole(Role role) => guild.addMemberRole(this, role);

  /// Removes a role from this member.
  Future removeRole(Role role) => guild.removeMemberRole(this, role);

  Member._raw(this.user, this.guild,
      {this.nickname, this.roles, this.deafened, this.muted});

  static Future<Member> _fromMap(
      Map<String, dynamic> obj, DiscordClient client, Guild guild) async {
    final roleList = <Role>[];
    final List<String> roles = obj["roles"];
    for (int i = 0; i < roles.length; i++) {
      final roleId = roles[i];
      final role =
          guild.roles.firstWhere((r) => r.id.toString() == roleId.toString());
      roleList.add(role);
    }
    return new Member._raw(
        await User._fromMap(obj["user"] as Map<String, dynamic>, client), guild,
        roles: roleList,
        nickname: obj["nick"] as String,
        deafened: obj["deaf"] as bool,
        muted: obj["mute"] as bool)
      ..client = client;
  }
}
