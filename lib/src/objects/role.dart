part of '../../dartsicord.dart';

/// A Role resource. Create with [Guild.createRole].
class Role extends _Resource {
  static int _permissionToRaw(List<RolePermission> permissions) =>
      permissions.fold(0, (p, c) => p + _permissionMap[c]);

  static List<RolePermission> _permissionFromRaw(int raw,
          {List<RolePermission> preset = RolePermission.values}) =>
      preset.where((p) => raw & _permissionMap[p] != 0).toList();

  static final Map<RolePermission, int> _permissionMap = {
    RolePermission.createInstantInvite: 1 << 0,
    RolePermission.kickMembers: 1 << 1,
    RolePermission.banMembers: 1 << 2,
    RolePermission.administrator: 1 << 3,
    RolePermission.manageChannels: 1 << 4,
    RolePermission.manageGuild: 1 << 5,
    RolePermission.addReactions: 1 << 6,
    RolePermission.viewAuditLog: 1 << 7,
    RolePermission.readMessages: 1 << 10,
    RolePermission.sendMessages: 1 << 11,
    RolePermission.sendTtsMessages: 1 << 12,
    RolePermission.manageMessages: 1 << 13,
    RolePermission.embedLinks: 1 << 14,
    RolePermission.attachFiles: 1 << 15,
    RolePermission.readMessageHistory: 1 << 16,
    RolePermission.mentionEveryone: 1 << 17,
    RolePermission.useExternalEmojis: 1 << 18,
    RolePermission.connect: 1 << 20,
    RolePermission.speak: 1 << 21,
    RolePermission.muteMembers: 1 << 22,
    RolePermission.deafenMembers: 1 << 23,
    RolePermission.moveMembers: 1 << 24,
    RolePermission.useVoiceActivation: 1 << 25,
    RolePermission.changeNickname: 1 << 26,
    RolePermission.manageNicknames: 1 << 27,
    RolePermission.manageRoles: 1 << 28,
    RolePermission.manageWebhooks: 1 << 29,
    RolePermission.manageEmojis: 1 << 30
  };

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

  /// A list of [RolePermission] enums generated from the [permissionsRaw] variable.
  List<RolePermission> get permissions => _permissionFromRaw(permissionsRaw);

  /// Whether or not this role is created and managed by a bot user.
  bool managed;

  /// Whether or not this role is mentionable.
  bool mentionable;

  Role._raw(this.name, this.id,
      {this.color,
      this.hoisted,
      this.position,
      this.permissionsRaw,
      this.managed,
      this.mentionable,
      this.guild});

  static Role _fromMap(Map<String, dynamic> obj, DiscordClient client) =>
      new Role._raw(obj["name"] as String, new Snowflake(obj["id"]),
          hoisted: obj["hoist"] as bool,
          position: obj["position"] as int,
          permissionsRaw: obj["permissions"] as int,
          managed: obj["managed"] as bool,
          mentionable: obj["mentionable"] as bool)
        ..client = client;
}
