import "package:dartsicord/dartsicord.dart";

void main() {
  final client = new DiscordClient();

  client.onMessage.listen((event) async {
    if (event.message.content.toLowerCase() == "ping")
      // method 1
      await event.message.reply("pong");
      // method 2
      // await event.channel.sendMessage("pong");
  });

  client.connect("YOUR-TOKEN");
}