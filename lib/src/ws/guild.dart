import "../internals.dart";
import "../client.dart";

import "channel.dart";
import "user.dart";

class Guild extends DiscordObject {
  /// Name of guild.
  String name;

  int id;

  List<Channel> channels = [];
  List<TextChannel> get textChannels => channels.where((c) => c is TextChannel);

  Guild(this.name, this.id);

  static Guild fromDynamic(dynamic obj, DiscordClient client) {
    final g = new Guild(obj["name"], obj["id"]);
    g.client = client;

    if (obj["channels"] != null) {
      for(int i = 0; i < obj["channels"].length; i++) {
        if (obj["channels"][i]["type"] != 0)
          continue;
        final channel = TextChannel.fromDynamic(obj["channels"][i], client, guild: g);
        g.channels.add(channel);
      }
    }

    return g;
  }
}