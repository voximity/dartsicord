# dartsicord

This is a basic Dart library intending to provide fundamental functionality to Discord's API.
Many features are missing from this library. It is expandable, so I am open to modification.

Currently, this library is able to process basic text commands and reply accordingly.
This library will go as far as full text functionality but no voice functionality.

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

Feel free to fork and contribute. Try to keep my style of code, or else I might get mad. That means double quotes
and decent organization. I'll still probably fix any consistency issues after you've made a pull request.