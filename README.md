# dartsicord

[![Build Status](https://travis-ci.org/voximity/dartsicord.svg?branch=master)](https://travis-ci.org/voximity/dartsicord)
[![Pub](https://img.shields.io/pub/v/dartsicord.svg)](https://pub.dartlang.org/packages/dartsicord)
[![Discord](https://discordapp.com/api/guilds/394664225626390538/widget.png)](https://discord.gg/d7PMs5K)

dartsicord is a Dart library intending to provide partial to full functionality of Discord's API.
This library started out as a fun project, but it has become a serious project that I'd like to finish.
This library is not at a stable state quite yet, but I'd love for you to give it a try and throw some issues
at my face so I can catch them and fix them.

This library does *not* support voice. It may in the future, but this is a low-priority feature.

## Why

dartsicord intends to be a simple, lightweight, efficient Discord library for building basic to large bots.
There's no fuss over basic things you need to get done. The library simplifies the API quite a bit.

## Issues

Issues are good! I hope you find some. I'd be more than happy to fix them. Just use the Issues tab (which I regularly maintain)
and put your words and issues there.

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

If you are too worried you'll break something, that's alright! I'm looking for those who would write unit tests (in the `test` directory) and more examples (in the `example` directory). I'm open to anything!
