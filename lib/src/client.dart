import "package:http/http.dart" as http;

import "dart:async";
import "dart:convert";
import "dart:io";

import "route.dart";
import "ws/guild.dart";
import "ws/channel.dart";
import "ws/message.dart";
import "ws/user.dart";

class DiscordClient {
  Timer _heartbeat;
  WebSocket _socket;
  int _lastSeq = null;

  String token;

  Future _getGateway() async {
    final route = new Route(this) + "gateway";
    final response = await route.get();
    return JSON.decode(response.body)["url"];
  }

  void _sendHeartbeat(Timer timer) {
    print("sending heartbeat");
    _socket.add(JSON.encode({
      "op": 1,
      "d": _lastSeq
    }));
  }



  DiscordClient() {

  }

  Future connect(String token) async {
    this.token = token;

    final gateway = await _getGateway();
    print(gateway);
    _socket = await WebSocket.connect(gateway + "?v=6&encoding=json");

    _socket.listen((payloadRaw) {
      final payload = JSON.decode(payloadRaw);
      final opcode = payload["op"];
      final data = payload["d"];

      print(payloadRaw);

      if (payload["s"] != null)
        _lastSeq = payload["s"];

      switch (opcode) {
        case 0: // Dispatch
          final event = payload["t"];
          
          break;
        case 1: // Heartbeat
          _sendHeartbeat(_heartbeat);
          break;
        case 7: // Reconnect
          break;
        case 9: // Invalid Session
          break;
        case 10: // Hello
          _heartbeat = new Timer.periodic(new Duration(milliseconds: data["heartbeat_interval"]), _sendHeartbeat);
          _socket.add(JSON.encode({
            "op": 2,
            "s": _lastSeq,
            "d": {
              "token": token,
              "properties": {
                "\$os": "windows",
                "\$browser": "discord-dart",
                "\$device": "discord-dart"
              },
              "compress": false,
              "large_threshold": 250
            }
          }));
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