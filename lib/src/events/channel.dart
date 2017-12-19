import 'dart:async';

import "../ws/guild.dart";
import "../ws/user.dart";
import "../ws/channel.dart";
import "../ws/message.dart";
import "../ws/emoji.dart";

import "../internals.dart";

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
class ChannelPinsUpdateEvent {
  /// The channel in which pins have been updated.
  TextChannel channel;
  /// A [DateTime] of the most recently pinned pin.
  DateTime lastPinAt;

  ChannelPinsUpdateEvent(this.channel, {this.lastPinAt});

  static Future<Null> construct(Packet packet) async {
    final channel = await packet.client.getTextChannel(packet.data["channel_id"]);
    final lastPinAt = packet.data["last_pin_timestamp"] != null ? DateTime.parse(packet.data["last_pin_timestamp"]) : null;

    final event = new ChannelPinsUpdateEvent(channel, lastPinAt: lastPinAt);
    packet.client.onChannelPinsUpdate.add(event);
  }
}