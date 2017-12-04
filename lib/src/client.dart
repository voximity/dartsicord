import "package:http/http.dart" as http;

import "dart:async";
import "dart:convert";
import "dart:io";

import "internals.dart";
import "event.dart";
import "ws/guild.dart";
import "ws/channel.dart";
import "ws/message.dart";
import "ws/user.dart";

class DiscordObject {
  DiscordClient client;
}

class DiscordClient extends EventExhibitor {
  Timer _heartbeat;
  WebSocket _socket;
  int _lastSeq = null;

  String token;
  List<Guild> guilds;
  bool ready = false;
  int userId;

  Future _getGateway() async {
    final route = new Route(this) + "gateway";
    final response = await route.get();
    return JSON.decode(response.body)["url"];
  }

  void _sendHeartbeat(Timer timer) {
    print("sending heartbeat");
    _socket.add(new Packet(data: _lastSeq).toString());
  }

  EventStream<ReadyEvent> onReady;
  EventStream<GuildCreateEvent> onGuildCreate;
  EventStream<MessageCreateEvent> onMessage;

  void _defineEvents() {
    onReady = createEvent();
    onGuildCreate = createEvent();
    onMessage = createEvent();
  }

  Guild getGuild(int id) => guilds.firstWhere((g) => g.id == id);
  Channel getChannel(int id) => guilds.firstWhere((g) => g.channels.any((c) => c.id == id)).channels.firstWhere((c) => c.id == id);

  DiscordClient() {
    _defineEvents();

    guilds = [];
  }

  Future sendMessage(String content, TextChannel channel) async {
    final route = new Route(this) + "channels" + channel.id.toString() + "messages";
    final response = route.post({
      "content": content
    }, headers: {"Authorization": "Bot $token"});
  }

  Future connect(String token) async {
    this.token = token;

    final gateway = await _getGateway();
    print(gateway);
    _socket = await WebSocket.connect(gateway + "?v=6&encoding=json");

    _socket.listen((payloadRaw) {
      final payload = JSON.decode(payloadRaw);
      final packet = new Packet(
        data: payload["d"],
        event: payload["t"],
        opcode: payload["op"],
         seq: payload["s"]);

      //print(payloadRaw);

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
              userId = packet.data["user"]["id"];
              break;
            case "GUILD_CREATE":
              final event = new GuildCreateEvent();
              /*final guild = new Guild(packet.data["name"], packet.data["id"]);
              for (int i = 0; i < packet.data["channels"].length; i++) {
                if (packet.data["channels"][i]["type"] != 0)
                  continue;
                
                final channel = new GuildTextChannel();
                channel.guild = guild;
                channel.id = packet.data["channels"][i]["id"];
                channel.name = packet.data["channels"][i]["name"];
                channel.client = this;
                guild.channels.add(channel);
              }
              guild.client = this;*/
              final guild = Guild.fromDynamic(packet.data, this);
              event.guild = guild;
              guilds.add(guild);

              if (ready)
                onGuildCreate.add(event);
              break;
            case "MESSAGE_CREATE":
              final event = new MessageCreateEvent();
              final message = Message.fromDynamic(packet.data, this);

              event.message = message;

              onMessage.add(event);
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
          print("sending identify");
          break;
        case 11: // Heartbeat ACK
          break;
        default:
          break;
      }
    }, onError: (e) {
      print(e.toString());
    }, onDone: () {
      print("done");
    }, cancelOnError: true);
  }
}