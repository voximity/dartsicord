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

  int shard;
  int shardCount;

  String token;
  TokenType tokenType;

  List<Guild> guilds;
  bool ready = false;

  User user;

  EventStream<ReadyEvent> onReady;
  EventStream<ResumedEvent> onResumed;
  EventStream<GuildCreateEvent> onGuildCreate;
  EventStream<GuildUpdateEvent> onGuildUpdate;
  EventStream<GuildDeleteEvent> onGuildDelete;
  EventStream<GuildBanAddEvent> onBanAdd;
  EventStream<GuildBanRemoveEvent> onBanRemove;
  EventStream<GuildMemberAddEvent> onMemberAdd;
  EventStream<GuildMemberUpdateEvent> onMemberUpdate;
  EventStream<GuildMemberRemoveEvent> onMemberRemove;
  EventStream<ChannelCreateEvent> onChannelCreate;
  EventStream<ChannelUpdateEvent> onChannelUpdate;
  EventStream<ChannelDeleteEvent> onChannelDelete;
  EventStream<MessageCreateEvent> onMessage;
  EventStream<MessageDeleteEvent> onMessageDelete;

  // Internal methods

  Future _getGateway() async {
    final route = new Route() + "gateway";
    final response = await route.get(client: this);
    return JSON.decode(response.body)["url"];
  }

  void _sendHeartbeat(Timer timer) {
    _socket.add(new Packet(data: _lastSeq).toString());
  }

  void _defineEvents() {
    onReady = createEvent();
    onResumed = createEvent();
    onGuildCreate = createEvent();
    onGuildUpdate = createEvent();
    onGuildDelete = createEvent();
    onBanAdd = createEvent();
    onBanRemove = createEvent();
    onMemberAdd = createEvent();
    onMemberUpdate = createEvent();
    onMemberRemove = createEvent();
    onChannelCreate = createEvent();
    onChannelUpdate = createEvent();
    onChannelDelete = createEvent();
    onMessage = createEvent();
    onMessageDelete = createEvent();
  }

  // External methods

  Guild getGuild(int id) =>
    guilds.firstWhere((g) => g.id == id);
  
  Future<Channel> getChannel(int id) async {
    final route = Channel.endpoint + id.toString();
    final response = await route.get(client: this);
    return Channel.fromDynamic(JSON.decode(response.body), this);
  }
  Future<TextChannel> getTextChannel(int id) async =>
    await getChannel(id) as TextChannel;

  Future<Message> sendMessage(String content, TextChannel channel, {Embed embed}) async {
    final route = Channel.endpoint + channel.id.toString() + "messages";
    final response = await route.post({
      "content": content,
      "embed": embed != null ? embed.toDynamic() : null
    }, client: this);
    final parsed = JSON.decode(response.body);
    return Message.fromDynamic(parsed, this);
  }

  Future<TextChannel> createDirectMessage(User recipient) async {
    final route = User.endpoint + "@me" + "channels";
    final response = await route.post({
      "recipient_id": recipient.id
    }, client: this);
    final channel = TextChannel.fromDynamic(JSON.decode(response.body), this);
    return channel;
  }

  // Constructor

  DiscordClient({this.shard, this.shardCount}) {
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
            case "RESUMED":
              onResumed.add(new ResumedEvent());
              break;
            case "GUILD_CREATE":
              final guild = await Guild.fromDynamic(packet.data, this);

              guilds.add(guild);
              if (ready)
                onGuildCreate.add(new GuildCreateEvent(guild));
              break;
            case "GUILD_UPDATE":
              final guild = await Guild.fromDynamic(packet.data, this);

              guilds.removeWhere((x) => x.id == guild.id);
              guilds.add(guild);
              if (ready)
                onGuildUpdate.add(new GuildUpdateEvent(guild));
              break;
            case "GUILD_DELETE":
              final guild = await Guild.fromDynamic(packet.data, this);

              guilds.remove(guild);
              if (ready)
                onGuildDelete.add(new GuildDeleteEvent(guild));
              break;
            case "GUILD_BAN_ADD":
              final member = await Member.fromDynamic(packet.data, this, await Guild.fromDynamic(packet.data["guild"], this));

              member.guild.bans.add(member);
              if (ready)
                onBanAdd.add(new GuildBanAddEvent(member));
              break;
            case "GUILD_BAN_REMOVE":
              final member = await Member.fromDynamic(packet.data, this, await Guild.fromDynamic(packet.data["guild"], this));

              member.guild.bans.remove(member);
              if (ready)
                onBanRemove.add(new GuildBanRemoveEvent(member));
              break;
            case "GUILD_MEMBER_ADD":
              final guild = await Guild.fromDynamic(packet.data["guild_id"], this);
              final member = await Member.fromDynamic(packet.data, this, guild);

              member.guild.members.add(member);
              onMemberAdd.add(new GuildMemberAddEvent(member, guild));
              break;
            case "GUILD_MEMBER_UPDATE":
              final guild = await Guild.fromDynamic(packet.data["guild_id"], this);
              final member = await Member.fromDynamic(packet.data, this, guild);

              guild.members.removeWhere((x) => x.id == member.id);
              guild.members.add(member);
              onMemberUpdate.add(new GuildMemberUpdateEvent(member, guild));
              break;
            case "GUILD_MEMBER_REMOVE":
              final guild = await Guild.fromDynamic(packet.data["guild_id"], this);
              final member = await Member.fromDynamic(packet.data, this, guild);

              member.guild.members.remove(member);
              onMemberRemove.add(new GuildMemberRemoveEvent(member, guild));
              break;
            case "CHANNEL_CREATE":
              final channel = await Channel.fromDynamic(packet.data, this);

              if (Channel.types[channel.type] == ChannelType.GuildText)
                channel.guild.channels.add(channel);

              onChannelCreate.add(new ChannelCreateEvent(channel));

              break;
            case "CHANNEL_UPDATE":
              final channel = await Channel.fromDynamic(packet.data, this);

              if (Channel.types[channel.type] == ChannelType.GuildText) {
                channel.guild.channels.removeWhere((c) => c.id == channel.id);
                channel.guild.channels.add(channel);
              }

              onChannelUpdate.add(new ChannelUpdateEvent(channel));

              break;
            case "CHANNEL_DELETE":
              final channel = await Channel.fromDynamic(packet.data, this);

              if (Channel.types[channel.type] == ChannelType.GuildText)
                channel.guild.channels.remove(channel);

              onChannelDelete.add(new ChannelDeleteEvent(channel));

              break;
            case "MESSAGE_CREATE":
              final message = await Message.fromDynamic(packet.data, this);

              onMessage.add(new MessageCreateEvent(message,
                author: message.author,
                channel: message.channel,
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
                "\$browser": "dartsicord",
                "\$device": "dartsicord"
              },
              "shard": shard != null ? [shard, shardCount] : null,
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