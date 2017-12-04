import "../route.dart";
import "user.dart";
import "guild.dart";
import "channel.dart";

abstract class Message {
  String content;
  User author;
  int id;

  
}



class GuildMessage implements Message {
  String content;
  User author;
  int id;

  Guild guild;
  TextChannel channel;
}

class DMMessage implements Message {
  String content;
  User author;
  int id;
}