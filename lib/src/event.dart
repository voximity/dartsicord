part of dartsicord;

class _EventStream<T> extends Stream<T> {
  StreamController<T> _controller;
  Stream<T> _stream;

  _EventStream() {
    _controller = new StreamController.broadcast();
    _stream = _controller.stream;
  }

  StreamSubscription<T> listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError}) => 
      _stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  void add(T event) => _controller.add(event);
  Future close() => _controller.close();
}

abstract class _EventExhibitor {
  final List<_EventStream> _events = [];

  _EventStream createEvent() {
    final event = new _EventStream();
    _events.add(event);

    return event;
  }

  Future<List> destroyEvents() => Future.wait(_events.map((event) => event.close()));
}

typedef Future<Null> WebSocketEventConstructor(Packet packet);

class ReadyEvent {
  ReadyEvent();

  static Future<Null> construct(Packet packet) async {
    packet.client
      ..ready = true
      ..sessionId = packet.data["session_id"]
      ..user = await User._fromMap(packet.data["user"], packet.client);

    final event = new ReadyEvent();
    packet.client.onReady.add(event);
  }
}
class UserUpdateEvent {
  UserUpdateEvent();

  static Future<Null> construct(Packet packet) async {
    packet.client.user = await User._fromMap(packet.data, packet.client);

    final event = new UserUpdateEvent();
    packet.client.onUserUpdate.add(event);
  }
}
class PresenceUpdateEvent {
  /// The user in which presence has been updated.
  User user;
  /// The [Game] object representing the game the user is playing, if any.
  Game game;
  /// The status of the user, based on the [StatusType] enum.
  StatusType status;

  PresenceUpdateEvent(this.user, this.status, {this.game});

  static Future<Null> construct(Packet packet) async {
    final user = await User._fromMap(packet.data["user"], packet.client);
    final game = packet.data["game"] != null ? await Game._fromMap(packet.data["game"], packet.client) : null;
    final status = Game.statuses[packet.data["status"]];

    final event = new PresenceUpdateEvent(user, status, game: game);
    packet.client.onPresenceUpdate.add(event);
  }
}