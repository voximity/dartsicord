class Permission {
  Permission(this.name, {this.raw});

  /// The name of the permission.
  String name;

  /// The raw value of the permission.
  int raw;

  static int toRaw(List<Permission> permissions) {
    int totalRaw = 0;
    permissions.forEach((p) => totalRaw += p.raw);
    return totalRaw;
  }
  static List<Permission> fromRaw(int raw, List<Permission> preset) {
    final permissionList = [];
    preset.forEach((p) {
      if ((raw & p.raw) != 0)
        permissionList.add(p);
    });
    return permissionList;
  }

  static List<Permission> RolePermissions = [
    new Permission("CreateInstantInvite", raw: 1 << 0),
    new Permission("KickMembers", raw: 1 << 1),
    new Permission("BanMembers", raw: 1 << 2),
    new Permission("Administrator", raw: 1 << 3),
    new Permission("ManageChannels", raw: 1 << 4),
    new Permission("ManageGuild", raw: 1 << 5),
    new Permission("AddReactions", raw: 1 << 6),
    new Permission("ViewAuditLog", raw: 1 << 7),

    new Permission("ReadMessages", raw: 1 << 10),
    new Permission("SendMessages", raw: 1 << 11),
    new Permission("SendTtsMessages", raw: 1 << 12),
    new Permission("ManageMessages", raw: 1 << 13),
    new Permission("EmbedLinks", raw: 1 << 14),
    new Permission("AttachFiles", raw: 1 << 15),
    new Permission("ReadMessageHistory", raw: 1 << 16),
    new Permission("MentionEveryone", raw: 1 << 17),
    new Permission("UseExternalEmojis", raw: 1 << 18),

    new Permission("Connect", raw: 1 << 20),
    new Permission("Speak", raw: 1 << 21),
    new Permission("MuteMembers", raw: 1 << 22),
    new Permission("DeafenMembers", raw: 1 << 23),
    new Permission("MoveMembers", raw: 1 << 24),
    new Permission("UseVoiceActivation", raw: 1 << 25),
    new Permission("ChangeNickname", raw: 1 << 26),
    new Permission("ManageNicknames", raw: 1 << 27),
    new Permission("ManageRoles", raw: 1 << 28),
    new Permission("ManageWebhooks", raw: 1 << 29),
    new Permission("ManageEmojis", raw: 1 << 30),
  ];
}