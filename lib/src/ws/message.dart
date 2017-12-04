import "dart:async";
import "../internals.dart";
import "../client.dart";
import "user.dart";
import "guild.dart";
import "channel.dart";

class Message extends DiscordObject {
  String content;
  User author;
  TextChannel textChannel;
  int id;

  Message(this.content, this.id, {this.author, this.textChannel});
  
  static Message fromDynamic(dynamic obj, DiscordClient client) {
    return new Message(obj["content"], obj["id"],
    author: User.fromDynamic(obj["author"], client),
    textChannel: client.getChannel(obj["channel_id"]))..client = client;
  }

  Future reply(String text) async => this.textChannel.sendMessage(text);
}



class GuildMessage extends Message {
  String content;
  User author;
  int id;

  Guild guild;
  GuildTextChannel guildTextChannel;

  GuildMessage(String content, int id, {User author}) : super(content, id, author: author);
}

class DMMessage extends Message {
  String content;
  User author;
  int id;

  DMMessage(String content, int id, {User author}) : super(content, id, author: author);
}