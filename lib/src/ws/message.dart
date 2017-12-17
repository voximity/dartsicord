import "dart:async";
import "../internals.dart";
import "../client.dart";
import "../exception.dart";
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

  int id;

  //
  // Methods
  //

  Future react(String emoji) async {
    final route = Channel.endpoint + channel.id.toString() + "messages" + id.toString() + "reactions" + emoji + "@me";
    await route.put({}, client: client);
  }

  Future edit(String content, {Embed embed}) async {
    if (!isAuthor)
      throw new NotAuthorException();

    final route = Channel.endpoint + channel.id.toString() + "messages" + id.toString();
    this.content = content;
    this.embed ??= embed;

    await route.patch({"content": content, "embed": embed.toDynamic()});
  }

  Future delete() async {
    final route = Channel.endpoint + channel.id.toString() + "messages" + id.toString();
    await route.delete();
  }

  Future<Message> reply(String text, {Embed embed}) async => this.channel.sendMessage(text, embed: embed);

  //
  // Constructors
  //

  Message(this.content, this.id, {this.author, this.channel, this.guild});
  
  static Future<Message> fromDynamic(dynamic obj, DiscordClient client) async =>
    new Message(obj["content"], obj["id"],
    author: await User.fromDynamic(obj["author"], client),
    channel: await client.getChannel(obj["channel_id"]),
    guild: (await client.getTextChannel(obj["channel_id"])).guild)..client = client;
}