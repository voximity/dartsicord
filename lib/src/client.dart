import "dart:async";
import "dart:convert";
import "dart:io";

import "enums.dart";
import "event.dart";

import "events/channel.dart";
import "events/guild.dart";
import "events/message.dart";

import "networking.dart";

import "objects/channel.dart";
import "objects/embed.dart";
import "objects/game.dart";
import "objects/guild.dart";
import "objects/message.dart";
import "objects/user.dart";

class DiscordClient extends EventExhibitor {
  Timer _heartbeat;
  WebSocket _socket;
  int _lastSeq;
  bool _closed = false;

  Route get api => new Route(client: this);

  String sessionId;

  /// The shard of the current client.
  int shard;

  /// The total number of shards that this bot is using.
  int shardCount;

  /// The token of this client.
  String token;

  /// The token type of this client.
  TokenType tokenType;

  /// A list of Guilds this client is in.
  List<Guild> guilds;

  /// Whether or not this client has recieved the `READY` payload yet.
  bool ready = false;

  /// The [User] representing this guild.
  User user;

  //
  // Events
  //

  /// Fired when the client receives the `READY` payload.
  EventStream<ReadyEvent> onReady;
  /// Fired when the client's user updates.
  EventStream<UserUpdateEvent> onUserUpdate;

  /// Fired when the client sees a guild created. Not fired before [ready] is reached.
  EventStream<GuildCreateEvent> onGuildCreate;
  /// Fired when the client sees a guild update.
  EventStream<GuildUpdateEvent> onGuildUpdate;
  /// Fired when the client is removed from a guild.
  EventStream<GuildRemoveEvent> onGuildRemove;
  /// Fired when the client sees a guild become unavailable.
  EventStream<GuildUnavailableEvent> onGuildUnavailable;

  /// Fired when the client sees a user banned.
  EventStream<UserBannedEvent> onUserBanned;
  /// Fired when the client sees a user unbanned.
  EventStream<UserUnbannedEvent> onUserUnbanned;
  /// Fired when the client sees a guild update its emojis.
  EventStream<GuildEmojisUpdateEvent> onGuildEmojisUpdated;
  /// Fired when the client sees a guild update its integrations.
  EventStream<GuildIntegrationsUpdateEvent> onGuildIntegrationsUpdated;
  /// Fired when the client sees a member updated on its guild.
  EventStream<MemberUpdatedEvent> onMemberUpdated;
  /// Fired when the client sees a user join a guild.
  EventStream<UserAddedEvent> onUserAdded;
  /// Fired when the client sees a user get removed from a guild. (left, kicked, banned, etc.)
  EventStream<UserRemovedEvent> onUserRemoved;

  /// Fired when the client sees a role created in a guild.
  EventStream<RoleCreatedEvent> onRoleCreated;
  /// Fired when the client sees a role updated in a guild.
  EventStream<RoleUpdatedEvent> onRoleUpdated;
  /// Fired when the client sees a role deleted in a guild.
  EventStream<RoleDeletedEvent> onRoleDeleted;

  /// Fired when the client sees a message created.
  EventStream<MessageCreateEvent> onMessage;
  /// Fired when the client sees a message delete.
  EventStream<MessageDeleteEvent> onMessageDelete;
  /// Fired when the client sees messages bulk-deleted.
  EventStream<MessageDeleteBulkEvent> onMessageBulkDelete;

  /// Fired when the client sees a reaction created on a message.
  EventStream<ReactionAddEvent> onReactionAdd;
  /// Fired when the client sees a reaction removed from a message.
  EventStream<ReactionRemoveEvent> onReactionRemove;
  /// Fired when the client sees all reactions removed from a message.
  EventStream<ReactionRemoveAllEvent> onReactionRemoveAll;

  /// Fired when the client sees a channel created.
  EventStream<ChannelCreateEvent> onChannelCreate;
  /// Fired when the client sees a channel updated.
  EventStream<ChannelUpdateEvent> onChannelUpdate;
  /// Fired when the client sees a channel deleted.
  EventStream<ChannelDeleteEvent> onChannelDelete;
  /// Fired when the client sees a channel update its pins.
  EventStream<ChannelPinsUpdateEvent> onChannelPinsUpdate;

  /// Fired when the client sees a user start typing in a channel.
  EventStream<TypingStartEvent> onTypingStart;

  /// Fired when the client sees a channel update its webhooks.
  EventStream<WebhooksUpdateEvent> onWebhooksUpdate;

  /// Fired when the client sees a user update their presence.
  EventStream<PresenceUpdateEvent> onPresenceUpdate;

  // Internal methods

  Future _getGateway() async {
    final response = await (api + "gateway").get();
    return JSON.decode(response.body)["url"];
  }

  void _sendHeartbeat(Timer timer) {
    final packet = new Packet(data: _lastSeq, opcode: 1);
    _socket.add(packet.toString());
  }

  void _defineEvents() {
    onReady = createEvent();
    onUserUpdate = createEvent();

    onGuildCreate = createEvent();
    onGuildUpdate = createEvent();
    onGuildRemove = createEvent();
    onGuildUnavailable = createEvent();

    onGuildEmojisUpdated = createEvent();
    onGuildIntegrationsUpdated = createEvent();
    onMemberUpdated = createEvent();
    onUserAdded = createEvent();
    onUserRemoved = createEvent();

    onUserBanned = createEvent();
    onUserUnbanned = createEvent();

    onReactionAdd = createEvent();
    onReactionRemove = createEvent();
    onReactionRemoveAll = createEvent();

    onMessage = createEvent();
    onMessageDelete = createEvent();
    onMessageBulkDelete = createEvent();

    onChannelCreate = createEvent();
    onChannelUpdate = createEvent();
    onChannelDelete = createEvent();
    onChannelPinsUpdate = createEvent();

    onTypingStart = createEvent();

    onWebhooksUpdate = createEvent();

    onPresenceUpdate = createEvent();
  }

  Future<String> _avatarData(File avatar, String headerType) async {
    final bytes = await avatar.readAsBytes();
    final encoded = BASE64.encode(bytes);
    return "data:image/$headerType;base64,$encoded";
  }


  // External methods

  /// Modify the client's user. Note that the [avatar] parameter is currently experimental.
  Future modify({String username, File avatar, String avatarFileType = "jpeg"}) async {
    final query = {"username": username};

    if (avatar != null) {
      final data = await _avatarData(avatar, avatarFileType);
      print(data);
      query["avatar"] = data;
    }

    final response = await (api + "users" + "@me").patch(query);
    return User.fromMap(JSON.decode(response.body), this);
  }

  /// Get a guild from the client's cache.
  Guild getGuild(dynamic id) => 
    guilds.firstWhere((g) =>
      g.id.toString() == id.toString()
    );
  
  /// Get a channel given its [id].
  Future<Channel> getChannel(dynamic id) async {
    if (!guilds.any((g) => g.channels.any((c) => c.id == id))) // Check if this channel is already cached.
      return guilds.firstWhere((c) => c.id == id).channels.firstWhere((c) => c.id == id);

    final response = await (api + "channels" + id).get();
    return Channel.fromMap(JSON.decode(response.body), this);
  }

  /// Get a text channel given its [id].
  Future<TextChannel> getTextChannel(dynamic id) =>
    getChannel(id);



  // External method references

  /// Sends a message to a text channel. See [TextChannel.sendMessage]
  Future<Message> sendMessage(String content, TextChannel channel, {Embed embed}) =>
    channel.sendMessage(content, embed: embed);

  /// Creates a direct message channel with the given [recipient].
  Future<TextChannel> createDirectMessage(User recipient) =>
    recipient.createDirectMessage();
  
  /// Updates the client's status using a [StatusType] status enum.
  /// 
  /// Optionally, you can include a self-made [Game] object and whether
  /// or not the client should be considered AFK.
  void updateStatus(StatusType status, {Game game, bool afk = false}) {
    final query = {
      "status": Game.statusesR[status],
      "afk": afk,
      "game": game?.toMap(),
      "since": null
    };
    final packet = new Packet(
      opcode: 3,
      data: query,
      seq: _lastSeq,

      client: this
    );
    
    _socket.add(packet.toString());
  }



  // Constructor

  DiscordClient({this.shard, this.shardCount}) {
    _defineEvents();

    guilds = [];
  }

  Future<dynamic> disconnect({bool reconnect = false}) async {
    _closed = !reconnect;
    return await _socket.close();
  }

  void _sendIdentify() {
    _socket.add(new Packet(opcode: 2, seq: _lastSeq, data: {
      "token": token,
      "properties": {
        "\$os": "windows",
        "\$browser": "dartsicord",
        "\$device": "dartsicord"
      },
      //"shard": shard != null ? [shard, shardCount] : null,
      "compress": false,
      "large_threshold": 250
    }).toString());
  }

  Future<Null> _establishConnection(String token, {TokenType tokenType = TokenType.bot, bool reconnecting = false}) async {
    _closed = false;

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
        seq: payload["s"],
        client: this);

      if (packet.seq != null)
        _lastSeq = packet.seq;

      switch (packet.opcode) {
        case 0: // Dispatch
          final event = payload["t"];
          if (ready) {
            switch (event) {
              case "READY":
                await ReadyEvent.construct(packet);
                break;

              case "CHANNEL_CREATE":
                await ChannelCreateEvent.construct(packet);
                break;
              case "CHANNEL_UPDATE":
                await ChannelUpdateEvent.construct(packet);
                break;
              case "CHANNEL_DELETE":
                await ChannelDeleteEvent.construct(packet);
                break;
              case "CHANNEL_PINS_UPDATE":
                await ChannelPinsUpdateEvent.construct(packet);
                break;

              case "GUILD_CREATE":
                await GuildCreateEvent.construct(packet);
                break;
              case "GUILD_UPDATE":
                await GuildUpdateEvent.construct(packet);
                break;
              case "GUILD_DELETE":
                await GuildRemoveEvent.construct(packet); // This method checks if this event was fired because of unavailability or removal from a guild.
                break;
              
              case "GUILD_EMOJIS_UPDATE":
                await GuildEmojisUpdateEvent.construct(packet);
                break;
              case "GUILD_INTEGRATIONS_UPDATE":
                await GuildIntegrationsUpdateEvent.construct(packet);
                break;
              case "GUILD_MEMBER_UPDATE":
                await MemberUpdatedEvent.construct(packet);
                break;
              case "GUILD_MEMBER_ADD":
                await UserAddedEvent.construct(packet);
                break;
              case "GUILD_MEMBER_REMOVE":
                await UserRemovedEvent.construct(packet);
                break;

              case "USER_BANNED":
                await UserBannedEvent.construct(packet);
                break;
              case "USER_UNBANNED":
                await UserUnbannedEvent.construct(packet);
                break;
              
              case "GUILD_ROLE_CREATED":
                await RoleCreatedEvent.construct(packet);
                break;
              case "GUILD_ROLE_UPDATED":
                await RoleUpdatedEvent.construct(packet);
                break;
              case "GUILD_ROLE_DELETED":
                await RoleDeletedEvent.construct(packet);
                break;

              case "MESSAGE_CREATE":
                await MessageCreateEvent.construct(packet);
                break;
              case "MESSAGE_DELETE":
                await MessageDeleteEvent.construct(packet);
                break;
              case "MESSAGE_DELETE_BULK":
                await MessageDeleteBulkEvent.construct(packet);
                break;
              
              case "WEBHOOKS_UPDATE":
                await WebhooksUpdateEvent.construct(packet);
                break;

              case "PRESENCE_UPDATE":
                await PresenceUpdateEvent.construct(packet);
                break;

              default:
                break;
            }
          } else {
            if (event == "READY")
              await ReadyEvent.construct(packet);
            else if(event == "GUILD_CREATE")
              await GuildCreateEvent.construct(packet);
          }

          break;
        case 1: // Heartbeat
          _sendHeartbeat(_heartbeat);
          break;
        case 3: // Update Status
          break;
        case 7: // Reconnect
          await disconnect(reconnect: true);
          break;
        case 9: // Invalid Session
          await new Future.delayed(const Duration(seconds: 3));
          _sendIdentify();
          break;
        case 10: // Hello
          _heartbeat = new Timer.periodic(new Duration(milliseconds: packet.data["heartbeat_interval"]), _sendHeartbeat);
          if (reconnecting) {
            _socket.add(new Packet(opcode: 6, seq: _lastSeq, data: {
              "token": token,
              "session_id": sessionId,
              "seq": _lastSeq
            }));
          } else {
            _sendIdentify();
          }
          break;
        case 11: // Heartbeat ACK
          break;
        default:
          break;
      }
    }, onError: (e) {
      print(e.toString());
    }, onDone: () {
      _socket.close();
      _heartbeat.cancel();

      if (!_closed) {
        _reconnect();
      }
    }, cancelOnError: true);
  }

  Future<Null> _reconnect() =>
    _establishConnection(token, tokenType: tokenType, reconnecting: true);
  
  /// Connects to Discord's API.
  Future<Null> connect(String token, {TokenType tokenType = TokenType.bot}) =>
    _establishConnection(token, tokenType: tokenType, reconnecting: false);
}