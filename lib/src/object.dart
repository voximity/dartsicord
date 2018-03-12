part of dartsicord;

abstract class Resource {
  /// ID of the object.
  Snowflake id;

  /// The Client the object was instantiated by.
  DiscordClient client;
}

class Snowflake {
  int id;

  String toString() => id.toString();

  Snowflake(dynamic id) {
    this.id = id is String ? int.parse(id) : id;
  }
  
  int get hashCode => id.hashCode;
  bool operator ==(dynamic idOther) => id.toString() == idOther.toString();
}

