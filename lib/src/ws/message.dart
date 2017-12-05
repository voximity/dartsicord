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
  TextChannel textChannel;

  /// Guild the message was sent in, if any.
  Guild guild = null;

  /// Whether or not the message was created by the client user.
  bool get isAuthor => author.id == client.user.id;

  int id;

  //
  // Methods
  //

  Future edit(String content, {Embed embed}) async {
    if (!isAuthor)
      throw new NotAuthorException();

    final route = new Route(client) + "channels" + textChannel.id.toString() + "messages" + id.toString();
    this.content = content;
    this.embed ??= embed;

    await route.patch({"content": content, "embed": embed.toDynamic()});
  }

  Future delete() async {
    final route = new Route(client) + "channels" + textChannel.id.toString() + "messages" + id.toString();
    await route.delete();
  }

  Future<Message> reply(String text, {Embed embed}) async => this.textChannel.sendMessage(text, embed: embed);

  //
  // Constructor
  //

  Message(this.content, this.id, {this.author, this.textChannel, this.guild});
  
  static Message fromDynamic(dynamic obj, DiscordClient client) =>
    new Message(obj["content"], obj["id"],
    author: User.fromDynamic(obj["author"], client),
    textChannel: client.getTextChannel(obj["channel_id"]),
    guild: client.getTextChannel(obj["channel_id"]).guild)..client = client;
}