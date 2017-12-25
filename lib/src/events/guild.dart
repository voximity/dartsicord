import "dart:async";

import "../networking.dart";
import "../object.dart";
import "../objects/emoji.dart";
import "../objects/guild.dart";
import "../objects/role.dart";
import "../objects/user.dart";

class GuildCreateEvent {
  /// The created guild.
  Guild guild;
  GuildCreateEvent(this.guild);

  static Future<Null> construct(Packet packet) async {
    final guild = await Guild.fromMap(packet.data, packet.client);
    if (!packet.client.guilds.any((g) => g.id == guild.id))
      packet.client.guilds.add(guild);

    if (packet.client.ready)
      packet.client.onGuildCreate.add(new GuildCreateEvent(guild));
  }
}
class GuildUpdateEvent {
  /// The updated guild.
  Guild guild;
  GuildUpdateEvent(this.guild);

  static Future<Null> construct(Packet packet) async {
    var guild = await Guild.fromMap(packet.data, packet.client);
    
    final existing = packet.client.guilds.firstWhere((g) => g.id == guild.id)
      ..name = guild.name
      ..channels = guild.channels
      ..emojis = guild.emojis
      ..roles = guild.roles;
    guild = existing;

    packet.client.onGuildUpdate.add(new GuildUpdateEvent(guild));
  }
}
class GuildUnavailableEvent {
  /// The partial guild.
  Guild guild;

  GuildUnavailableEvent(this.guild);

  static Future<Null> construct(Packet packet) async {
    final guild = await Guild.fromMap(packet.data, packet.client);

    packet.client.onGuildUnavailable.add(new GuildUnavailableEvent(guild));
  }
}
class GuildRemoveEvent {
  /// The guild the client was removed from.
  Guild guild;

  GuildRemoveEvent(this.guild);

  static Future<Null> construct(Packet packet) async {
    if (packet.data["unavailable"] != null)
      return await GuildUpdateEvent.construct(packet);
    
    packet.data["unavailable"] = true;
    final guild = await Guild.fromMap(packet.data, packet.client);

    packet.client.onGuildRemove.add(new GuildRemoveEvent(guild));
  }
}
class UserBannedEvent {
  /// The guild the user was banned from.
  Guild guild;
  /// The user that was banned.
  User user;

  UserBannedEvent({this.guild, this.user});

  static Future<Null> construct(Packet packet) async {
    final guild = await packet.client.getGuild(packet.data["guild_id"]);
    final user = await User.fromMap(packet.data, packet.client);

    packet.client.onUserBanned.add(new UserBannedEvent(guild: guild, user: user));
  }
}
class UserUnbannedEvent {
  /// The guild the user was unbanned from.
  Guild guild;
  /// The user that was banned.
  User user;

  UserUnbannedEvent({this.guild, this.user});

  static Future<Null> construct(Packet packet) async {
    final guild = await packet.client.getGuild(packet.data["guild_id"]);
    final user = await User.fromMap(packet.data, packet.client);

    packet.client.onUserUnbanned.add(new UserUnbannedEvent(guild: guild, user: user));
  }
}

class GuildEmojisUpdateEvent {
  /// The guild that the emojis have been updated in.
  Guild guild;
  /// The updated emojis for this guild.
  List<Emoji> get emojis => guild.emojis;

  GuildEmojisUpdateEvent(this.guild);

  static Future<Null> construct(Packet packet) async {
    final guild = packet.client.getGuild(packet.data["guild_id"]);
    final emojiList = [];
    packet.data["emojis"].forEach((e) async {
      final emoji = await Emoji.fromMap(e, packet.client, guild: guild);
      emojiList.add(emoji);
    });

    packet.client.onGuildEmojisUpdated.add(new GuildEmojisUpdateEvent(guild));
  }
}

class GuildIntegrationsUpdateEvent {
  /// The guild in which integrations have been updated.
  Guild guild;

  GuildIntegrationsUpdateEvent(this.guild);

  static Future<Null> construct(Packet packet) async {
    final guild = packet.client.getGuild(packet.data["guild_id"]);

    packet.client.onGuildIntegrationsUpdated.add(new GuildIntegrationsUpdateEvent(guild));
  }
}

class MemberUpdatedEvent {
  /// The guild in which the user has been updated.
  Guild guild;
  /// The user that has been updated in the guild.
  User user;
  /// The member that has been updated in the guild.
  Member member;

  MemberUpdatedEvent(this.guild, this.user, {this.member});

  static Future<Null> construct(Packet packet) async {
    final guild = packet.client.getGuild(packet.data["guild_id"]);
    final user = await User.fromMap(packet.data["user"], packet.client);
    final member = await guild.getMember(user);

    final event = new MemberUpdatedEvent(guild, user, member: member);
    packet.client.onMemberUpdated.add(event);
  }
}

class UserAddedEvent {
  /// The guild in which the user has joined.
  Guild guild;
  /// The user that has joined the guild.
  User user;
  /// The member representing the user's status in this guild.
  Member member;

  UserAddedEvent(this.guild, this.user, {this.member});

  static Future<Null> construct(Packet packet) async {
    final guild = packet.client.getGuild(packet.data["guild_id"]);
    final user = await User.fromMap(packet.data["user"], packet.client);
    final member = await Member.fromMap(packet.data, packet.client, guild);
    
    final event = new UserAddedEvent(guild, user, member: member);

    packet.client.onUserAdded.add(event);
  }
}
class UserRemovedEvent {
  /// The guild in which the user has been removed.
  Guild guild;
  /// The user that has been removed from the guild.
  User user;

  UserRemovedEvent(this.guild, this.user);

  static Future<Null> construct(Packet packet) async {
    final guild = packet.client.getGuild(packet.data["guild_id"]);
    final user = await User.fromMap(packet.data["user"], packet.client);
    
    final event = new UserRemovedEvent(guild, user);

    packet.client.onUserRemoved.add(event);
  }
}

class RoleCreatedEvent {
  Guild guild;
  Role role;

  RoleCreatedEvent(this.guild, this.role);

  static Future<Null> construct(Packet packet) async {
    final guild = packet.client.getGuild(packet.data["guild_id"]);
    final role = await Role.fromMap(packet.data["role"], packet.client)
      ..guild = guild;
    
    if (!guild.roles.any((r) => r.id == role.id))
      guild.roles.add(role);

    final event = new RoleCreatedEvent(guild, role);
    packet.client.onRoleCreated.add(event);
  }
}
class RoleUpdatedEvent {
  Guild guild;
  Role role;

  RoleUpdatedEvent(this.guild, this.role);

  static Future<Null> construct(Packet packet) async {
    final guild = packet.client.getGuild(packet.data["guild_id"]);
    final role = await Role.fromMap(packet.data["role"], packet.client)
      ..guild = guild;
    
    guild.roles
      ..removeWhere((r) => r.id == role.id)
      ..add(role);

    final event = new RoleUpdatedEvent(guild, role);
    packet.client.onRoleUpdated.add(event);
  }
}
class RoleDeletedEvent {
  Guild guild;
  Snowflake roleId;

  RoleDeletedEvent(this.guild, {this.roleId});

  static Future<Null> construct(Packet packet) async {
    final guild = packet.client.getGuild(packet.data["guild_id"]);
    final roleId = new Snowflake(packet.data["role_id"]);

    guild.roles.removeWhere((r) => r.id == roleId);

    final event = new RoleDeletedEvent(guild, roleId: roleId);
    packet.client.onRoleDeleted.add(event);
  }
}