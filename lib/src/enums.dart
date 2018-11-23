part of '../dartsicord.dart';

/// The type of the channel.
enum ChannelType { guildText, dm, guildVoice, groupDm, guildCategory }

/// The token type of the authorized bot.
enum TokenType { bot, user }

/// The user's status.
enum StatusType { online, doNotDisturb, away, invisible, offline }

/// Directs the library how to download messages.
enum MessageDownloadType { before, after, around }

/// The activity the user is engaged in.
enum ActivityType { game, stream, listen, watch }

/// The type of permission overwrite for the channel.
enum OverwriteType { role, member }

/// The role permissions.
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
