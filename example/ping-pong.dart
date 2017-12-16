import "package:dartsicord/dartsicord.dart";

void main() {
  final client = new DiscordClient();

  client.onMessage.listen((event) async {
    if (event.message.content.toLowerCase() == "ping")
      await event.message.reply("pong");
  });

  client.connect("YOUR-TOKEN");
}