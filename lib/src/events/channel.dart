import 'dart:async';
import 'dart:convert';

import "../networking.dart";
import "../objects/channel.dart";
import "../objects/guild.dart";
import "../objects/webhook.dart";

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
      channel.guild.channels
        ..removeWhere((c) => c.id == channel.id)
        ..add(channel);
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
class WebhooksUpdateEvent {
  /// The channel in which webhooks have been updated.
  TextChannel channel;
  /// The guild that contains the channel that webhooks have been updated.
  Guild guild;

  WebhooksUpdateEvent(this.channel, {this.guild});

  static Future<Null> construct(Packet packet) async {
    final channel = await packet.client.getTextChannel(packet.data["channel_id"]);
    final route = channel.localEndpoint + "webhooks";
    final response = await route.get(client: packet.client);
    final webhooks = JSON.decode(response.body);
    channel.webhooks = webhooks.map((w) async => await Webhook.fromMap(w, packet.client));

    final event = new WebhooksUpdateEvent(channel, guild: channel.guild);
    packet.client.onWebhooksUpdate.add(event);
  }
}