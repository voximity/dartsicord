import "dart:async";
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

    await route.patch({"content": content, "embed": embed.toMap()});
  }

  /// Delete the message.
  Future delete() async {
    final route = Channel.endpoint + channel.id + "messages" + id;
    await route.delete();
  }

  /// Reply to the message. See [DiscordClient.sendMessage] for full documentation.
  Future<Message> reply(String text, {Embed embed}) async => await this.channel.sendMessage(text, embed: embed);

  //
  // Constructors
  //

  Message(this.content, this.id, {this.author, this.channel, this.guild});
  
  static Future<Message> fromMap(dynamic obj, DiscordClient client) async =>
    new Message(obj["content"], new Snowflake(obj["id"]),
    author: obj["author"] != null ? await User.fromMap(obj["author"], client) : null,
    channel: await client.getChannel(obj["channel_id"]),
    guild: (await client.getTextChannel(obj["channel_id"])).guild)..client = client;
}