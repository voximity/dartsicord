part of dartsicord;

/// A Webhook resource. Create with [TextChannel.createWebhook].
class Webhook extends _Resource {
  _Route get _endpoint => client.api + "webhooks" + id;

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
  Future<Null> delete() =>
    _endpoint.delete();

  /// Modify this webhook using the given positional parameters [name], [avatar], and [channel].
  Future<Null> modify({String name, String avatar, Channel channel}) async {
    final query = {};
    if (name != null)
      query["name"] = name;
    if (avatar != null)
      query["avatar"] = avatar;
    if (channel != null)
      query["channel_id"] = channel.id.id;

    final response = await _endpoint.patch(query);
    final object = json.decode(await response.readAsString());

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
      "embeds": embeds.map((e) => e._toMap())
    };
    await (_endpoint + token).post(query);
  }

  Webhook._raw(this.id, this.name, this.token, {this.avatar, this.channel, this.guild});

  static Future<Webhook> _fromMap(Map<String, dynamic> obj, DiscordClient client) async =>
    new Webhook._raw(new Snowflake(obj["id"]), obj["name"], obj["token"],
      avatar: obj["avatar"],
      channel: await client.getTextChannel(obj["channel_id"]),
      guild: obj["guild_id"] != null ? client.getGuild(obj["guild"]) : null);
}