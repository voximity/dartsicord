import "dart:async";
import "dart:math";

import "package:dartsicord/dartsicord.dart";

class Giveaway {
  DateTime createdAt;
  Duration length;
  String name;
  TextChannel channel;
  Message message;

  Giveaway(this.name, {this.length, this.createdAt, this.message});
}

void main() {
  final client = new DiscordClient();

  client.onMessage.listen((ev) async {
    final message = ev.message;

    if (message.content.startsWith("giveaway ")) {
      final name = message.content.substring(9); // Find the name of the giveaway.

      final emoji = new Emoji("🎊"); // Create an emoji object to use for reactions.
      final embed = new Embed() // Build the giveaway...
        ..withTitle("A giveaway has begun!")
        ..withDescription(name)
        ..addField("How to get in", "React with the existing reaction to enter the giveaway.");
      
      final giveawayMessage = await message.reply("", embed: embed) // Reply with the embed and...
        ..react(emoji); // react with the emoji.

      // Create our proprietary giveaway object...
      final giveaway = new Giveaway(name, length: const Duration(seconds: 60), createdAt: new DateTime.now(), message: giveawayMessage);

      await new Future.delayed(giveaway.length); // Wait the length of the giveaway (60 seconds)

      final reactors = await giveawayMessage.getReactions(emoji); // Get the reactors for the emoji we used.
      final participants = reactors.where((u) => u.id != client.user.id); // Get only the reactors that aren't ourselves.
      final random = new Random(); // Create a new random number generator.
      final winner = participants.elementAt(random.nextInt(participants.length)); // Get a random participant.

      await giveawayMessage.deleteReactions(); // Remove all participants.
      await giveawayMessage.edit("${winner.mention} wins the giveaway!"); // Edit the message and show who won.
    }
  });

  client.connect("token");
}