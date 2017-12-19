import 'dart:async';

import "ws/guild.dart";
import "ws/user.dart";
import "ws/channel.dart";
import "ws/message.dart";

import "internals.dart";

//
// Event system
//

class EventStream<T> extends Stream<T> {
  StreamController<T> _controller;
  Stream<T> _stream;

  EventStream() {
    _controller = new StreamController.broadcast();
    _stream = _controller.stream;
  }

  StreamSubscription<T> listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError}) => 
      _stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  void add(T event) => _controller.add(event);
  Future close() => _controller.close();
}

abstract class EventExhibitor {
  final List<EventStream> _events = [];

  EventStream createEvent() {
    final event = new EventStream();
    _events.add(event);

    return event;
  }

  Future<List> destroyEvents() => Future.wait(_events.map((event) => event.close()));
}

//
// Events
//

class ReadyEvent {
  ReadyEvent();

  static Future<Null> construct(Packet packet) async {
    packet.client.ready = true;
    packet.client.user = await User.fromMap(packet.data, packet.client);

    final event = new ReadyEvent();
    packet.client.onReady.add(event);
  }
}

class ChannelCreateEvent {
  /// The created channel.
  Channel channel;
  ChannelCreateEvent(this.channel);

  static Future<Null> construct(Packet packet) async {
    final channel = await Channel.fromMap(packet.data, packet.client);
    if (channel.guild != null && !channel.guild.channels.any((c) => c.id == channel.id))
      channel.guild.channels.add(channel);
    
    final event = new ChannelCreateEvent(channel);
    packet.client.onChannelCreate.add(event);
  }
}
class ChannelUpdateEvent {
  /// The updated channel.
  Channel channel;
  ChannelUpdateEvent(this.channel);

  static Future<Null> construct(Packet packet) async {
    final channel = await Channel.fromMap(packet.data, packet.client);
    if (channel.guild != null) {
      channel.guild.channels.removeWhere((c) => c.id == channel.id);
      channel.guild.channels.add(channel);
    }
    
    final event = new ChannelUpdateEvent(channel);
    packet.client.onChannelUpdate.add(event);
  }
}
class ChannelDeleteEvent {
  /// The deleted channel. Methods will not work on this instance.
  Channel channel;
  ChannelDeleteEvent(this.channel);

  static Future<Null> construct(Packet packet) async {
    final channel = await Channel.fromMap(packet.data, packet.client);
    if (channel.guild != null)
      channel.guild.channels.removeWhere((c) => c.id == channel.id);
    
    final event = new ChannelUpdateEvent(channel);
    packet.client.onChannelUpdate.add(event);
  }
}

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
    final guild = await Guild.fromMap(packet.data, packet.client);
    packet.client.guilds.removeWhere((g) => g.id == guild.id);
    packet.client.guilds.add(guild);

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

    packet.client.onUserUnbanned.add(new UserBannedEvent(guild: guild, user: user));
  }
}

class MessageCreateEvent {
  /// The channel the message was created in.
  Channel channel;
  /// The guild of the channel that the message was created in. This may be null as this may be a non-guild message.
  Guild guild;
  /// The user that created this message. May be null due to webhooks.
  User author;
  /// The message that was created.
  Message message;

  MessageCreateEvent(this.message, {this.author, this.guild, this.channel});

  static Future<Null> construct(Packet packet) async {
    final message = await Message.fromMap(packet.data, packet.client);
    final event = new MessageCreateEvent(message,
      author: message.author,
      channel: message.channel,
      guild: message.guild);
    packet.client.onMessage.add(event);
  }
}
class MessageDeleteEvent {
  /// The [TextChannel] this message was deleted in.
  TextChannel channel;
  /// A snowflake ID of the message that was deleted.
  int messageId;

  MessageDeleteEvent(this.channel, this.messageId);

  static Future<Null> construct(Packet packet) async {
    final event = new MessageDeleteEvent(
      await packet.client.getChannel(packet.data["channel_id"]),
      packet.data["id"]
    );
    packet.client.onMessageDelete.add(event);
  }
}