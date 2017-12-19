import "client.dart";

abstract class DiscordObject {
  /// ID of the object.
  Snowflake id;

  /// The Client the object was instantiated by.
  DiscordClient client;
}
class Snowflake {
  int id;

  String toString() => id.toString();

  Snowflake(this.id);
  
  int get hashCode => id.hashCode;
  bool operator ==(dynamic idOther) => id.toString() == idOther.toString();
}

