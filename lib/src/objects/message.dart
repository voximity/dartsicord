part of dartsicord;

/// A Message resource. Create with [TextChannel.sendMessage] or [DiscordClient.sendMessage].
class Message extends _Resource {
  _Route get _endpoint => channel._endpoint + "messages" + id;

  /// Content of the message.
  String content;

  /// Embed of the message.
  Embed embed;

  /// Author of the message.
  User author;

  /// Channel the message was sent in.
  TextChannel channel;

  /// Guild the message was sent in, if any.
  Guild guild;

  /// When the message was created.
  DateTime createdAt;

  /// When the message was edited.
  DateTime editedAt;

  /// The users that are being mentioned in this message.
  List<User> mentions = [];

  /// The roles that are being mentioned in this message.
  List<Role> roleMentions = [];

  /// Whether or not the message was created by the client user.
  bool get isAuthor => author.id == client.user.id;

  Snowflake id;



  //
  // Methods
  //

  /// React to the message using [emoji].
  /// 
  /// You can use [Guild.emojis] to find the emoji you'd like to use,
  /// or you can instantiate an Emoji object yourself given the name,
  /// which can be raw emoji unicode. For example, `new Emoji("🎊")`
  Future<Null> react(Emoji emoji) =>
    (_endpoint + "reactions" + emoji + "@me").put({});

  /// Removes a previously created reaction from the message using [emoji].
  /// 
  /// See [Message.react] for more information on how to use this method.
  Future<Null> removeReaction(Emoji emoji) =>
    (_endpoint + "reactions" + emoji + "@me").delete();

  /// Gets all users who reacted to the message using [emoji] given the [limit], if any.
  /// 
  /// [limit] will default to 100. Positional retrieval will be implemented some time soon.
  Future<List<User>> getReactions(Emoji emoji, {int limit = 100}) async {
    final _Route = _endpoint + "reactions" + emoji
      ..url += "?limit=$limit";
    final response = await _Route.get();
    return Future.wait(json.decode(await response.readAsString()).map((u) async => await User._fromMap(u, client)));
  }

  /// Deletes all reactions created on this message.
  Future<Null> deleteReactions() =>
    (_endpoint + "reactions").delete();

  /// Pin a message to its [channel].
  Future<Null> pin() =>
    (channel._endpoint + "pins" + id).put({});

  /// Unpins a message from its [channel].
  Future<Null> unPin() =>
    (channel._endpoint + "pins" + id).delete();

  /// Edit the message, given it is yours.
  Future<Null> edit(String content, {Embed embed}) async {
    if (!isAuthor)
      throw new ForbiddenException();

    final newMessage = await _endpoint.patch({"content": content, "embed": embed?._toMap()});
    this.content = content;
    this.embed ??= embed;
    
    editedAt = DateTime.parse(json.decode(await newMessage.readAsString())["edited_timestamp"]);
  }

  /// Delete the message.
  Future<Null> delete() =>
    _endpoint.delete();

  /// Reply to the message. See [DiscordClient.sendMessage] for full documentation.
  Future<Message> reply(String text, {Embed embed}) async =>
    await channel.sendMessage(text, embed: embed);

  //
  // Constructors
  //

  Message._raw(this.content, this.id, {this.author, this.channel, this.guild});
  
  static Future<Message> _fromMap(Map<String, dynamic> obj, DiscordClient client) async {
    final message = new Message._raw(obj["content"], new Snowflake(obj["id"]),
      author: obj["author"] != null ? await User._fromMap(obj["author"], client) : null,
      channel: await client.getChannel(obj["channel_id"]),
      guild: (await client.getTextChannel(obj["channel_id"])).guild)

      ..createdAt = DateTime.parse(obj["timestamp"])
      ..editedAt = obj["edited_timestamp"] != null ? DateTime.parse(obj["edited_timestamp"]) : null
      ..client = client;

    obj["mentions"]?.forEach((m) async {
      final user = await User._fromMap(m, client);

      message.mentions.add(user);
    });

    obj["role_mentions"]?.forEach((m) async {
      final role = await Role._fromMap(m, client)
        ..guild = message.guild;

      message.roleMentions.add(role);
    });

    return message;
  }
}