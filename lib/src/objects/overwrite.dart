import "../client.dart";
import "../enums.dart";
import "../object.dart";

import "role.dart";

class Overwrite {
  static Map<String, OverwriteType> internalMap = {
    "role": OverwriteType.role,
    "member": OverwriteType.member
  };

  /// The target object's ID that this will affect. Check [type] before assuming overwrite type.
  Snowflake targetId;
  DiscordClient client;

  /// The type of overwrite this is.
  OverwriteType type;
  /// A [List] of [RolePermission] enums to allow.
  List<RolePermission> allow = [];
  /// A [List] of [RolePermission] enums to deny.
  List<RolePermission> deny = [];

  Overwrite(this.targetId, this.type, {this.allow, this.deny});

  static Overwrite fromMap(Map<String, dynamic> obj, DiscordClient client) =>
    new Overwrite(new Snowflake(obj["id"]), Overwrite.internalMap[obj["type"]],
      allow: Role.permissionFromRaw(obj["allow"]),
      deny: Role.permissionFromRaw(obj["deny"]));
  
  Map<String, dynamic> toMap() =>
    {
      "id": targetId.toString(),
      "type": (new Map.fromIterables(internalMap.values, internalMap.keys))[type],
      "allow": Role.permissionToRaw(allow),
      "deny": Role.permissionToRaw(deny)
    };
}