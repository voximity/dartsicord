import "dart:async";
import "dart:convert";

import "../client.dart";
import "../internals.dart";
import "../object.dart";

import "channel.dart";
import "embed.dart";
import "guild.dart";
import "user.dart";

class Webhook extends Resource {
  static Route get endpoint => new Route() + "webhooks";
  Route get localEndpoint => endpoint + id;

  Snowflake id;

  /// The name of the Webhook.
  String name;
  /// The avatar of the Webhook.
  String avatar;
  /// The secure token of the Webhook.
  String token;

  /// The Webhook's creator.
  User author;
  /// The Webhook's channel.
  TextChannel channel;
  /// The Webhook's guild.
  Guild guild;

  /// Delete this webhook.
  Future<Null> delete() async {
    final route = localEndpoint;
    await route.delete(client: client);
  }

  /// Modify this webhook using the given positional parameters [name], [avatar], and [channel].
  Future<Null> modify({String name, String avatar, Channel channel}) async {
    final query = {};
    if (name != null)
      query["name"] = name;
    if (avatar != null)
      query["avatar"] = avatar;
    if (channel != null)
      query["channel_id"] = channel.id.id;
    
    final route = localEndpoint;
    final response = await route.patch(query, client: client);
    final object = JSON.decode(response.body);

    this.name = object["name"];
    this.avatar = object["avatar"];
    this.channel = await client.getChannel(object["channel_id"]);
  }

  /// Execute this webhook.
  Future<Null> execute(String content, {String username, bool tts, List<Embed> embeds}) async {
    final query = {
      "content": content,
      "username": username,
      "tts": tts,
      "embeds": embeds.map((e) => e.toMap())
    };

    final route = localEndpoint + token;
    await route.post(query, client: client);
  }

  Webhook(this.id, this.name, this.token, {this.avatar, this.channel, this.guild});

  static Future<Webhook> fromMap(Map<String, dynamic> obj, DiscordClient client) async =>
    new Webhook(new Snowflake(obj["id"]), obj["name"], obj["token"],
      avatar: obj["avatar"],
      channel: await client.getTextChannel(obj["channel_id"]),
      guild: obj["guild_id"] != null ? client.getGuild(obj["guild"]) : null);
}