import 'dart:async';

import "ws/guild.dart";
import "ws/user.dart";
import "ws/channel.dart";
import "ws/message.dart";

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

//
// Events
//

class ReadyEvent {
  
}

class ResumedEvent {
  
}

class GuildCreateEvent {
  Guild guild;

  GuildCreateEvent(this.guild);
}

class GuildDeleteEvent {
  Guild guild;

  GuildDeleteEvent(this.guild);
}

class ChannelCreateEvent {
  Channel channel;

  ChannelCreateEvent(this.channel);
}

class ChannelUpdateEvent {
  Channel channel;

  ChannelUpdateEvent(this.channel);
}

class ChannelDeleteEvent {
  Channel channel;

  ChannelDeleteEvent(this.channel);
}

class MessageCreateEvent {
  Channel channel;
  Guild guild;
  User author;
  Message message;

  MessageCreateEvent(this.message, {this.author, this.guild, this.channel});
}

class MessageDeleteEvent {
  TextChannel channel;
  int messageId;

  MessageDeleteEvent(this.channel, this.messageId);
}