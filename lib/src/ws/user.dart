import "../internals.dart";
import "../client.dart";
import "guild.dart";
import "channel.dart";
import "message.dart";

class User extends DiscordObject {
  String username;
  String discriminator;
  int id;

  User(this.username, this.discriminator, this.id);

  static User fromDynamic(dynamic obj, DiscordClient client) {
    return new User(obj["username"], obj["discriminator"], obj["id"])..client = client;
  }
}

class Member extends User {
  Guild guild;

  Member(String username, String discriminator, int id) : super(username, discriminator, id);
}