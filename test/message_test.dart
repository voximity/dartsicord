import "dart:async";
import "dart:io";

import "package:dartsicord/dartsicord.dart";
import "package:test/test.dart";

void main() {
  final env = Platform.environment;

  DiscordClient client;

  setUpAll(() async {
    client = new DiscordClient();
    await client.connect(env["TOKEN"]);
    await client.onReady.first;
  });

  test("clients correctly cache their own user object", () {
    expect(client.user.partial, isFalse);
  });
  test("getting channels from the client returns a proper channel object", () async {
    final channel = await client.getTextChannel(394615331705847810);

    expect(channel.name, equals("general"));
  });
  test("sending messages returns a proper message object", () async {
    final channel = await client.getTextChannel(394615331705847810);
    final message = await channel.sendMessage("sending messages returns a proper message object");

    expect(message.content, startsWith("sending"));
  });
  test("deleting messages correctly delete messages", () async {
    final channel = await client.getTextChannel(394615331705847810);
    final message = await channel.sendMessage("deleting messages correctly delete messages");
    await message.delete();

    expect(channel.getMessage(message.id), throwsA(const isInstanceOf<NotFoundException>()));
  });

  tearDownAll(() async {
    await client.disconnect();
  });
}