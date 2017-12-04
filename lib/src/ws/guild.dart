import "../route.dart";
import "../client.dart";

import "channel.dart";
import "user.dart";

class Guild extends DiscordObject {
  String name;
  int id;
  List<TextChannel> channels = [];

  Guild(this.name, this.id);
}