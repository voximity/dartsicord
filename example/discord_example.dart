import "package:discord/discord.dart";

void main() {
  final client = new DiscordClient();

  client.onReady.listen((event) {
    print("Received ready payload");
  });
  client.onMessage.listen((event) async {
    final message = event.message;

    if (message.content == "ping") {
      print("got ping");
      print(message.textChannel.id);
      await message.reply("pong");
    }

  });

  client.connect("MzI0NjY4ODM5NjQ2MTk5ODEx.DQYjMg.jSw8DXHVeC_qKLP9yofXqPpJsPw");
}