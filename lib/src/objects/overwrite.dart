part of '../../dartsicord.dart';

/// An Overwrite object. Can be directly created and used with [TextChannel.modify] and [TextChannel.modifyPermission].
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

  static Overwrite _fromMap(Map<String, dynamic> obj) => new Overwrite(
      new Snowflake(obj["id"]), Overwrite.internalMap[obj["type"]],
      allow: Role._permissionFromRaw(obj["allow"] as int),
      deny: Role._permissionFromRaw(obj["deny"] as int));

  Map<String, dynamic> _toMap() => {
        "id": targetId.toString(),
        "type":
            (new Map.fromIterables(internalMap.values, internalMap.keys))[type],
        "allow": Role._permissionToRaw(allow),
        "deny": Role._permissionToRaw(deny)
      };
}
