import "dart:async";
import "../internals.dart";
import "../client.dart";
import "user.dart";
import "guild.dart";
import "channel.dart";

class Message extends DiscordObject {
  /// Content of the message.
  String content;

  /// Author of the message.
  User author;

  /// Channel the message was sent in.
  TextChannel textChannel;

  /// Guild the message was sent in, if any.
  Guild guild = null;

  int id;

  Message(this.content, this.id, {this.author, this.textChannel, this.guild});
  
  static Message fromDynamic(dynamic obj, DiscordClient client) =>
    new Message(obj["content"], obj["id"],
    author: User.fromDynamic(obj["author"], client),
    textChannel: client.getTextChannel(obj["channel_id"]),
    guild: client.getTextChannel(obj["channel_id"]).guild)..client = client;

  Future reply(String text) async => this.textChannel.sendMessage(text);
}