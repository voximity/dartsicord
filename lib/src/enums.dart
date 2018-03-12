part of dartsicord;

enum ChannelType {
  guildText,
  dm,
  guildVoice,
  groupDm,
  guildCategory
}

enum TokenType {
  bot,
  user
}

enum StatusType {
  online,
  doNotDisturb,
  away,
  invisible,
  offline
}

enum MessageDownloadType {
  before,
  after,
  around
}

enum ActivityType {
  game,
  stream,
  listen,
  watch
}

enum OverwriteType {
  role,
  member
}

enum RolePermission {
  createInstantInvite,
  kickMembers,
  banMembers,
  administrator,
  manageChannels,
  manageGuild,
  addReactions,
  viewAuditLog,

  readMessages,
  sendMessages,
  sendTtsMessages,
  manageMessages,
  embedLinks,
  attachFiles,
  readMessageHistory,
  mentionEveryone,
  useExternalEmojis,

  connect,
  speak,
  muteMembers,
  deafenMembers,
  moveMembers,
  useVoiceActivation,
  changeNickname,
  manageNicknames,
  manageRoles,
  manageWebhooks,
  manageEmojis
}