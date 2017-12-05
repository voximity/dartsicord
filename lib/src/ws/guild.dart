import "../internals.dart";
import "../client.dart";

import "channel.dart";
import "user.dart";

import "dart:async";
import "dart:convert";

class Guild extends DiscordObject {
  /// Name of guild.
  String name;

  int id;

  List<Channel> channels = [];
  List<Role> roles = [];
  List<TextChannel> get textChannels => channels.where((c) => c is TextChannel);

  Future<Member> getMember(User user) async {
    final route = new Route(client) + "guilds" + id.toString() + "members" + user.id.toString();
    final response = await route.get();
    return Member.fromDynamic(JSON.decode(response.body), client, this);
  }

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
    if (obj["roles"] != null) {
      for(int i = 0; i < obj["roles"].length; i++) {
        final role = Role.fromDynamic(obj["roles"][i], client);
        role.guild = g;
        g.roles.add(role);
      }
    }

    return g;
  }
}

class Role extends DiscordObject {
  int id;

  Guild guild;

  String name;
  int color;
  bool hoisted;
  int position;
  int permissionsRaw;
  bool managed;
  bool mentionable;

  Role(this.name, this.id, {this.color, this.hoisted, this.position, this.permissionsRaw, this.managed, this.mentionable, this.guild});

  static Role fromDynamic(dynamic obj, DiscordClient client) {
    return new Role(
      obj["name"], obj["id"],
      hoisted: obj["hoist"],
      position: obj["position"],
      permissionsRaw: obj["permissions"],
      managed: obj["managed"],
      mentionable: obj["mentionable"]
    )..client = client;
  }
}