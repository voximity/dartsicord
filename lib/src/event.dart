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
  Channel channel;
  ChannelCreateEvent(this.channel);

  static Future<Null> construct(Packet packet) async {
    final channel = await Channel.fromMap(packet.data, packet.client);
    if (channel.guild != null)
      channel.guild.channels.add(channel);
    
    final event = new ChannelCreateEvent(channel);
    packet.client.onChannelCreate.add(event);
  }
}
class ChannelUpdateEvent {
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
  Guild guild;
  GuildCreateEvent(this.guild);

  static Future<Null> construct(Packet packet) async {
    final guild = await Guild.fromMap(packet.data, packet.client);
    packet.client.guilds.add(guild);

    if (packet.client.ready)
      packet.client.onGuildCreate.add(new GuildCreateEvent(guild));
  }
}

class MessageCreateEvent {
  Channel channel;
  Guild guild;
  User author;
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
  TextChannel channel;
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