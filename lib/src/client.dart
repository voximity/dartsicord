import "package:http/http.dart" as http;

import "dart:async";
import "dart:convert";
import "dart:io";

import "internals.dart";
import "event.dart";
import "enums.dart";
import "ws/guild.dart";
import "ws/channel.dart";
import "ws/message.dart";
import "ws/user.dart";
import "ws/embed.dart";

class DiscordObject {
  /// ID of the object.
  int id;

  /// The Client the object was instantiated by.
  DiscordClient client;
}

class DiscordClient extends EventExhibitor {
  Timer _heartbeat;
  WebSocket _socket;
  int _lastSeq = null;

  String token;
  TokenType tokenType;

  List<Guild> guilds;
  bool ready = false;

  User user;

  EventStream<ReadyEvent> onReady;
  EventStream<GuildCreateEvent> onGuildCreate;
  EventStream<MessageCreateEvent> onMessage;
  EventStream<MessageDeleteEvent> onMessageDelete;

  // Internal methods

  Future _getGateway() async {
    final route = new Route(this) + "gateway";
    final response = await route.get();
    return JSON.decode(response.body)["url"];
  }

  void _sendHeartbeat(Timer timer) {
    _socket.add(new Packet(data: _lastSeq).toString());
  }

  void _defineEvents() {
    onReady = createEvent();
    onGuildCreate = createEvent();
    onMessage = createEvent();
    onMessageDelete = createEvent();
  }

  // External methods

  Guild getGuild(int id) =>
    guilds.firstWhere((g) => g.id == id);
  
  Future<Channel> getChannel(int id) async {
    final route = new Route(this) + "channels" + id.toString();
    final response = await route.get();
    return Channel.fromDynamic(JSON.decode(response.body), this);
  }
  Future<TextChannel> getTextChannel(int id) async =>
    await getChannel(id) as TextChannel;

  Future<Message> sendMessage(String content, TextChannel channel, {Embed embed}) async {
    final route = new Route(this) + "channels" + channel.id.toString() + "messages";
    final response = await route.post({
      "content": content,
      "embed": embed != null ? embed.toDynamic() : null
    });
    final parsed = JSON.decode(response.body);
    return Message.fromDynamic(parsed, this);
  }

  Future<TextChannel> createDirectMessage(User recipient) async {
    final route = new Route(this) + "users" + "@me" + "channels";
    final response = await route.post({
      "recipient_id": recipient.id
    });
    final channel = TextChannel.fromDynamic(JSON.decode(response.body), this);
    return channel;
  }

  // Constructor

  DiscordClient() {
    _defineEvents();

    guilds = [];
  }

  

  Future connect(String token, {TokenType tokenType = TokenType.Bot}) async {
    this.token = token;
    this.tokenType = tokenType;

    final gateway = await _getGateway();
    _socket = await WebSocket.connect(gateway + "?v=6&encoding=json");

    _socket.listen((payloadRaw) async {
      final payload = JSON.decode(payloadRaw);
      final packet = new Packet(
        data: payload["d"],
        event: payload["t"],
        opcode: payload["op"],
         seq: payload["s"]);

      if (packet.seq != null)
        _lastSeq = packet.seq;

      switch (packet.opcode) {
        case 0: // Dispatch
          final event = payload["t"];
          
          switch (event) {
            case "READY":
              final event = new ReadyEvent();
              onReady.add(event);
              ready = true;
              user = await User.fromDynamic(packet.data["user"], this);
              break;
            case "GUILD_CREATE":
              final guild = await Guild.fromDynamic(packet.data, this);

              guilds.add(guild);
              if (ready)
                onGuildCreate.add(new GuildCreateEvent(guild));
              break;
            case "MESSAGE_CREATE":
              final message = await Message.fromDynamic(packet.data, this);

              onMessage.add(new MessageCreateEvent(message,
                author: message.author,
                channel: message.textChannel,
                guild: message.guild
              ));
              break;
            case "MESSAGE_DELETE":
              onMessageDelete.add(new MessageDeleteEvent(
                await getChannel(packet.data["channel_id"]),
                packet.data["id"]
              ));
              break;
            default:
              break;
          }

          break;
        case 1: // Heartbeat
          _sendHeartbeat(_heartbeat);
          break;
        case 7: // Reconnect
          break;
        case 9: // Invalid Session
          break;
        case 10: // Hello
          _heartbeat = new Timer.periodic(new Duration(milliseconds: packet.data["heartbeat_interval"]), _sendHeartbeat);
          _socket.add(new Packet(opcode: 2, seq: _lastSeq, data: {
              "token": token,
              "properties": {
                "\$os": "windows",
                "\$browser": "discord-dart",
                "\$device": "discord-dart"
              },
              "compress": false,
              "large_threshold": 250
          }).toString());
          break;
        case 11: // Heartbeat ACK
          break;
        default:
          break;
      }
    }, onError: (e) {
      print(e.toString());
    }, onDone: () {
      print("ended");
    }, cancelOnError: true);
  }
}