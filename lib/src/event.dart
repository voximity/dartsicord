import 'dart:async';

import "ws/guild.dart";
import "ws/user.dart";
import "ws/channel.dart";
import "ws/message.dart";
import "ws/emoji.dart";

import "internals.dart";

//
// Event system
//

class EventStream<T> extends Stream<T> {
  StreamController<T> _controller;
  Stream<T> _stream;

  EventStream() {
    _controller = new StreamController.broadcast();
    _stream = _controller.stream;
  }

  StreamSubscription<T> listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError}) => 
      _stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  void add(T event) => _controller.add(event);
  Future close() => _controller.close();
}

abstract class EventExhibitor {
  final List<EventStream> _events = [];

  EventStream createEvent() {
    final event = new EventStream();
    _events.add(event);

    return event;
  }

  Future<List> destroyEvents() => Future.wait(_events.map((event) => event.close()));
}

class ReadyEvent {
  ReadyEvent();

  static Future<Null> construct(Packet packet) async {
    packet.client.ready = true;
    packet.client.user = await User.fromMap(packet.data, packet.client);

    final event = new ReadyEvent();
    packet.client.onReady.add(event);
  }
}