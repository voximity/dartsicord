# dartsicord
[![Build Status](https://travis-ci.org/voximity/dartsicord.svg?branch=master)](https://travis-ci.org/voximity/dartsicord)
[![Pub](https://img.shields.io/pub/v/dartsicord.svg)](https://pub.dartlang.org/packages/dartsicord)
[![Discord](https://discordapp.com/api/guilds/394664225626390538/widget.png)](https://discord.gg/d7PMs5K)

This is a Dart library intending to provide functionality to Discord's API. Many features are missing from this library. It is expandable, so I am open to modification.

This library has a relatively good feature base. Most important REST methods are added. It is well organized so modification shouldn't be difficult.

I plan to have all events and most REST methods in by 0.1.0. If and when voice support is added, I will release 1.0.0.

## Examples

A simple ping-pong bot can be located in the example directory, or can be found here.

```dart
import "package:dartsicord/dartsicord.dart";

void main() {
    final client = new DiscordClient();

    client.onMessage.listen((event) async {
        if (event.message.content.toLowerCase() == "ping")
            await event.message.reply("pong");
    });

    client.connect("YOUR-TOKEN");
}
```

## Contributing

Feel free to fork and contribute. Try to keep my style of code, or else I might get mad. That means double quotes and decent organization. I'll still probably fix any consistency issues after you've made a pull request.
