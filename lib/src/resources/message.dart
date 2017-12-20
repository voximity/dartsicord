import "dart:async";
import "dart:convert";
import "../internals.dart";
import "../client.dart";
import "../exception.dart";
import "../object.dart";
import "user.dart";
import "guild.dart";
import "channel.dart";
import "embed.dart";

class Message extends DiscordObject {
  /// Content of the message.
  String content;

  /// Embed of the message.
  Embed embed;

  /// Author of the message.
  User author;

  /// Channel the message was sent in.
  TextChannel channel;

  /// Guild the message was sent in, if any.
  Guild guild = null;

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
  Future react(String emoji) async {
    final route = Channel.endpoint + channel.id + "messages" + id + "reactions" + emoji + "@me";
    await route.put({}, client: client);
  }

  /// Edit the message, given it is yours.
  Future edit(String content, {Embed embed}) async {
    if (!isAuthor)
      throw new ForbiddenException();

    final route = Channel.endpoint + channel.id + "messages" + id;
    this.content = content;
    this.embed ??= embed;

    final newMessage = await route.patch({"content": content, "embed": embed.toMap()});
    
    editedAt = DateTime.parse(JSON.decode(newMessage.body)["edited_timestamp"]);
  }

  /// Delete the message.
  Future delete() async {
    final route = Channel.endpoint + channel.id + "messages" + id;
    await route.delete();
  }

  /// Reply to the message. See [DiscordClient.sendMessage] for full documentation.
  Future<Message> reply(String text, {Embed embed}) async => await channel.sendMessage(text, embed: embed);

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