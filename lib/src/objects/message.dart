import "dart:async";
import "dart:convert";

import "../client.dart";
import "../exception.dart";
import "../networking.dart";
import "../object.dart";

import "channel.dart";
import "embed.dart";
import "emoji.dart";
import "guild.dart";
import "role.dart";
import "user.dart";

class Message extends Resource {
  Route get endpoint => channel.endpoint + "messages" + id;

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
    (endpoint + "reactions" + emoji + "@me").put({});

  /// Removes a previously created reaction from the message using [emoji].
  /// 
  /// See [Message.react] for more information on how to use this method.
  Future<Null> removeReact(Emoji emoji) =>
    (endpoint + "reactions" + emoji + "@me").delete();

  /// Gets all users who reacted to the message using [emoji] given the [limit], if any.
  /// 
  /// [limit] will default to 100. Positional retrieval will be implemented some time soon.
  Future<List<User>> getReactions(Emoji emoji, {int limit = 100}) async {
    final route = endpoint + "reactions" + emoji
      ..url += "?limit=$limit";
    final response = await route.get();
    return Future.wait(JSON.decode(response.body).map((u) async => await User.fromMap(u, client)));
  }

  /// Deletes all reactions created on this message.
  Future<Null> deleteReactions() =>
    (endpoint + "reactions").delete();

  /// Pin a message to its [channel].
  Future<Null> pin() =>
    (channel.endpoint + "pins" + id).put({});

  /// Unpins a message from its [channel].
  Future<Null> unpin() =>
    (channel.endpoint + "pins" + id).delete();

  /// Edit the message, given it is yours.
  Future<Null> edit(String content, {Embed embed}) async {
    if (!isAuthor)
      throw new ForbiddenException();

    final newMessage = await endpoint.patch({"content": content, "embed": embed?.toMap()});
    this.content = content;
    this.embed ??= embed;
    
    editedAt = DateTime.parse(JSON.decode(newMessage.body)["edited_timestamp"]);
  }

  /// Delete the message.
  Future<Null> delete() =>
    endpoint.delete();

  /// Reply to the message. See [DiscordClient.sendMessage] for full documentation.
  Future<Message> reply(String text, {Embed embed}) async =>
    await channel.sendMessage(text, embed: embed);

  //
  // Constructors
  //

  Message(this.content, this.id, {this.author, this.channel, this.guild});
  
  static Future<Message> fromMap(Map<String, dynamic> obj, DiscordClient client) async {
    final message = new Message(obj["content"], new Snowflake(obj["id"]),
      author: obj["author"] != null ? await User.fromMap(obj["author"], client) : null,
      channel: await client.getChannel(obj["channel_id"]),
      guild: (await client.getTextChannel(obj["channel_id"])).guild)

      ..createdAt = DateTime.parse(obj["timestamp"])
      ..editedAt = obj["edited_timestamp"] != null ? DateTime.parse(obj["edited_timestamp"]) : null
      ..client = client;

    obj["mentions"]?.forEach((m) async {
      final user = await User.fromMap(m, client);

      message.mentions.add(user);
    });

    obj["role_mentions"]?.forEach((m) async {
      final role = await Role.fromMap(m, client)
        ..guild = message.guild;

      message.roleMentions.add(role);
    });

    return message;
  }
}