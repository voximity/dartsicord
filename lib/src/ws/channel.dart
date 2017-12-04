import "../route.dart";
import "guild.dart";
import "message.dart";
import "user.dart";

abstract class Channel {
  String name;
  int id;
}



class TextChannel implements Channel {
  String name;
  int id;
}

class GuildTextChannel implements TextChannel {
  String name;
  int id;

  Guild guild;
}

class VoiceChannel implements Channel {
  String name;
  int id;

  Guild guild;
}