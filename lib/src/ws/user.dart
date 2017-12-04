import "../route.dart";
import "guild.dart";
import "channel.dart";
import "message.dart";

class User {
  String username;
  int id;
}

class Member implements User {
  String username;
  int id;

  Guild guild;
}