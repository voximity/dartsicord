part of '../../dartsicord.dart';

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
    final Map<String, dynamic> data = packet.data;
    final message = await Message._fromMap(data, packet.client);
    final event = new MessageCreateEvent(message,
        author: message.author, channel: message.channel, guild: message.guild);
    packet.client.onMessage.add(event);
  }
}

class MessageDeleteEvent {
  /// The [TextChannel] this message was deleted in.
  TextChannel channel;

  /// A snowflake ID of the message that was deleted.
  Snowflake messageId;

  MessageDeleteEvent(this.channel, this.messageId);

  static Future<Null> construct(Packet packet) async {
    final Map<String, dynamic> data = packet.data;
    final event = new MessageDeleteEvent(
        await packet.client.getChannel(data["channel_id"]) as TextChannel,
        new Snowflake(data["id"]));
    packet.client.onMessageDelete.add(event);
  }
}

class MessageDeleteBulkEvent {
  /// The [TextChannel] these messages were deleted in.
  TextChannel channel;

  /// A list of [Snowflake] objects representing the deleted messages.
  List<Snowflake> messages;

  MessageDeleteBulkEvent(this.messages, this.channel);

  static Future<Null> construct(Packet packet) async {
    final channel =
        await packet.client.getTextChannel(packet.data["channel_id"]);
    final ids =
        (packet.data["ids"] as List).map((i) => new Snowflake(i)).toList();

    final event = new MessageDeleteBulkEvent(ids, channel);
    packet.client.onMessageBulkDelete.add(event);
  }
}

class ReactionAddEvent {
  /// The user id of the reactor. You will need to fetch this user through client methods if absolutely necessary.
  Snowflake userId;

  /// The channel id of the reactor. You will need to use `DiscordClient.getChannel` if necessary.
  Snowflake channelId;

  /// The message id of the reactor. You will need to use `DiscordClient.getChannel` and `Channel.getMessage` if necessary.
  Snowflake messageId;

  /// A partial emoji object representing the emoji that was used. Look for parameters `id` and `name`.
  Emoji emoji;

  ReactionAddEvent(this.emoji, {this.userId, this.channelId, this.messageId});

  static Future<Null> construct(Packet packet) async {
    final Map<String, dynamic> data = packet.data;
    final event = new ReactionAddEvent(
        await Emoji._fromMap(
            data["emoji"] as Map<String, dynamic>, packet.client),
        userId: new Snowflake(data["user_id"]),
        channelId: new Snowflake(data["channel_id"]),
        messageId: new Snowflake(data["message_id"]));
    packet.client.onReactionAdd.add(event);
  }
}

class ReactionRemoveEvent {
  /// The user id of the reactor. You will need to fetch this user through client methods if absolutely necessary.
  Snowflake userId;

  /// The channel id of the reaction. You will need to use `DiscordClient.getChannel` if necessary.
  Snowflake channelId;

  /// The message id of the reaction. You will need to use `DiscordClient.getChannel` and `Channel.getMessage` if necessary.
  Snowflake messageId;

  /// A partial emoji object representing the emoji that was used. Look for parameters `id` and `name`.
  Emoji emoji;

  ReactionRemoveEvent(this.emoji,
      {this.userId, this.channelId, this.messageId});

  static Future<Null> construct(Packet packet) async {
    final Map<String, dynamic> data = packet.data;
    final event = new ReactionRemoveEvent(
        await Emoji._fromMap(
            data["emoji"] as Map<String, dynamic>, packet.client),
        userId: new Snowflake(data["user_id"]),
        channelId: new Snowflake(data["channel_id"]),
        messageId: new Snowflake(data["message_id"]));
    packet.client.onReactionRemove.add(event);
  }
}

class ReactionRemoveAllEvent {
  /// The channel id of the message with reactions removed. You will need to use `DiscordClient.getChannel` if necessary.
  Snowflake channelId;

  /// The message id of the message with reactions removed. You will need to use `DiscordClient.getChannel` and `Channel.getMessage` if necessary.
  Snowflake messageId;

  ReactionRemoveAllEvent({this.channelId, this.messageId});

  static Future<Null> construct(Packet packet) async {
    final event = new ReactionRemoveAllEvent(
        channelId: new Snowflake(packet.data["channel_id"]),
        messageId: new Snowflake(packet.data["message_id"]));
    packet.client.onReactionRemoveAll.add(event);
  }
}
