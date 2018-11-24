part of '../../dartsicord.dart';

class ChannelCreateEvent {
  /// The created channel.
  Channel channel;
  ChannelCreateEvent(this.channel);

  static Future<Null> construct(Packet packet) async {
    final Map<String, dynamic> data = packet.data;
    final channel = await Channel._fromMap(data, packet.client);

    if (channel.guild != null &&
        !channel.guild.channels.any((c) => c.id == channel.id))
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
    final Map<String, dynamic> data = packet.data;
    var channel = await Channel._fromMap(data, packet.client);
    if (channel.guild != null) {
      final existing = channel.guild.channels
          .firstWhere((c) => c.id == channel.id)
            ..name = channel.name;

      if (existing is TextChannel && channel is TextChannel)
        existing
          ..nsfw = channel.nsfw
          ..overwrites = channel.overwrites
          ..position = channel.position
          ..topic = channel.topic
          ..webhooks = channel.webhooks
          ..recipients = channel.recipients;

      channel = existing;
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
    final Map<String, dynamic> data = packet.data;
    final channel = await Channel._fromMap(data, packet.client);
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
    final channel =
        await packet.client.getTextChannel(packet.data["channel_id"]);
    final lastPinAt = packet.data["last_pin_timestamp"] != null
        ? DateTime.parse(packet.data["last_pin_timestamp"] as String)
        : null;

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
    final channel =
        await packet.client.getTextChannel(packet.data["channel_id"]);
    final route = packet.client.api + "channels" + channel.id + "webhooks";
    final response = await route.get();
    final webhooks =
        (json.decode(response.body) as List).cast<Map<String, dynamic>>();
    channel.webhooks = await Future.wait(
        webhooks.map((w) => Webhook._fromMap(w, packet.client)));

    final event = new WebhooksUpdateEvent(channel, guild: channel.guild);
    packet.client.onWebhooksUpdate.add(event);
  }
}

class TypingStartEvent {
  /// The channel in which someone is typing.
  TextChannel channel;

  /// A [Snowflake] object representing the user that was typing. If you need this object, see `User.get`.
  Snowflake userId;

  TypingStartEvent(this.channel, this.userId);

  static Future<Null> construct(Packet packet) async {
    final channel =
        await packet.client.getTextChannel(packet.data["channel_id"]);
    final userId = new Snowflake(packet.data["user_id"]);

    final event = new TypingStartEvent(channel, userId);
    packet.client.onTypingStart.add(event);
  }
}
