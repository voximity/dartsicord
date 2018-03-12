library dartsicord;

/*export "src/client.dart";
export "src/enums.dart";
export "src/exception.dart";

export "src/objects/channel.dart";
export "src/objects/embed.dart";
export "src/objects/emoji.dart";
export "src/objects/game.dart";
export "src/objects/guild.dart";
export "src/objects/message.dart";
export "src/objects/user.dart";*/

import "dart:async";
import "dart:convert";
import "dart:io";

import "package:http/http.dart" as http;

part "src/events/channel.dart";
part "src/events/guild.dart";
part "src/events/message.dart";

part "src/objects/channel.dart";
part "src/objects/embed.dart";
part "src/objects/emoji.dart";
part "src/objects/game.dart";
part "src/objects/guild.dart";
part "src/objects/invite.dart";
part "src/objects/message.dart";
part "src/objects/overwrite.dart";
part "src/objects/role.dart";
part "src/objects/user.dart";
part "src/objects/webhook.dart";

part "src/client.dart";
part "src/enums.dart";
part "src/event.dart";
part "src/exception.dart";
part "src/networking.dart";
part "src/object.dart";