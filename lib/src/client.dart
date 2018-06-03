part of dartsicord;

/*
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
import "objects/user.dart";*/

class DiscordClient extends _EventExhibitor {
  final Map<String, WebSocketEventConstructor> _websocketEvents = {
    "READY": ReadyEvent.construct,
    "CHANNEL_CREATE": ChannelCreateEvent.construct,
    "CHANNEL_UPDATE": ChannelUpdateEvent.construct,
    "CHANNEL_DELETE": ChannelDeleteEvent.construct,
    "CHANNEL_PINS_UPDATE": ChannelPinsUpdateEvent.construct,
    "GUILD_CREATE": GuildCreateEvent.construct,
    "GUILD_UPDATE": GuildUpdateEvent.construct,
    "GUILD_DELETE": GuildRemoveEvent.construct,
    "GUILD_EMOJIS_UPDATE": GuildEmojisUpdateEvent.construct,
    "GUILD_INTEGRATIONS_UPDATE": GuildIntegrationsUpdateEvent.construct,
    "GUILD_MEMBER_UPDATE": MemberUpdatedEvent.construct,
    "GUILD_MEMBER_ADD": MemberAddedEvent.construct,
    "GUILD_MEMBER_REMOVE": MemberRemovedEvent.construct,
    "USER_BANNED": MemberBannedEvent.construct,
    "USER_UNBANNED": MemberUnbannedEvent.construct,
    "GUILD_ROLE_CREATED": RoleCreatedEvent.construct,
    "GUILD_ROLE_UPDATED": RoleUpdatedEvent.construct,
    "GUILD_ROLE_DELETED": RoleDeletedEvent.construct,
    "MESSAGE_CREATE": MessageCreateEvent.construct,
    "MESSAGE_DELETE": MessageDeleteEvent.construct,
    "MESSAGE_DELETE_BULK": MessageDeleteBulkEvent.construct,
    "WEBHOOKS_UPDATE": WebhooksUpdateEvent.construct,
    "PRESENCE_UPDATE": PresenceUpdateEvent.construct
  };

  Timer _heartbeat;
  WebSocket _socket;
  int _lastSeq;
  bool _closed = false;

  /// The global [_Route] used for all interactions with the Discord API.
  _Route get api => new _Route(client: this);

  /// The current session ID of this client.
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
  _EventStream<ReadyEvent> onReady;
  /// Fired when the client's user updates.
  _EventStream<UserUpdateEvent> onUserUpdate;

  /// Fired when the client sees a guild created. Not fired before [ready] is reached.
  _EventStream<GuildCreateEvent> onGuildCreate;
  /// Fired when the client sees a guild update.
  _EventStream<GuildUpdateEvent> onGuildUpdate;
  /// Fired when the client is removed from a guild.
  _EventStream<GuildRemoveEvent> onGuildRemove;
  /// Fired when the client sees a guild become unavailable.
  _EventStream<GuildUnavailableEvent> onGuildUnavailable;

  /// Fired when the client sees a user banned.
  _EventStream<MemberBannedEvent> onMemberBanned;
  /// Fired when the client sees a user unbanned.
  _EventStream<MemberUnbannedEvent> onMemberUnbanned;
  /// Fired when the client sees a guild update its emojis.
  _EventStream<GuildEmojisUpdateEvent> onGuildEmojisUpdated;
  /// Fired when the client sees a guild update its integrations.
  _EventStream<GuildIntegrationsUpdateEvent> onGuildIntegrationsUpdated;
  /// Fired when the client sees a member updated on its guild.
  _EventStream<MemberUpdatedEvent> onMemberUpdated;
  /// Fired when the client sees a user join a guild.
  _EventStream<MemberAddedEvent> onMemberAdded;
  /// Fired when the client sees a user get removed from a guild. (left, kicked, banned, etc.)
  _EventStream<MemberRemovedEvent> onMemberRemoved;

  /// Fired when the client sees a role created in a guild.
  _EventStream<RoleCreatedEvent> onRoleCreated;
  /// Fired when the client sees a role updated in a guild.
  _EventStream<RoleUpdatedEvent> onRoleUpdated;
  /// Fired when the client sees a role deleted in a guild.
  _EventStream<RoleDeletedEvent> onRoleDeleted;

  /// Fired when the client sees a message created.
  _EventStream<MessageCreateEvent> onMessage;
  /// Fired when the client sees a message delete.
  _EventStream<MessageDeleteEvent> onMessageDelete;
  /// Fired when the client sees messages bulk-deleted.
  _EventStream<MessageDeleteBulkEvent> onMessageBulkDelete;

  /// Fired when the client sees a reaction created on a message.
  _EventStream<ReactionAddEvent> onReactionAdd;
  /// Fired when the client sees a reaction removed from a message.
  _EventStream<ReactionRemoveEvent> onReactionRemove;
  /// Fired when the client sees all reactions removed from a message.
  _EventStream<ReactionRemoveAllEvent> onReactionRemoveAll;

  /// Fired when the client sees a channel created.
  _EventStream<ChannelCreateEvent> onChannelCreate;
  /// Fired when the client sees a channel updated.
  _EventStream<ChannelUpdateEvent> onChannelUpdate;
  /// Fired when the client sees a channel deleted.
  _EventStream<ChannelDeleteEvent> onChannelDelete;
  /// Fired when the client sees a channel update its pins.
  _EventStream<ChannelPinsUpdateEvent> onChannelPinsUpdate;

  /// Fired when the client sees a user start typing in a channel.
  _EventStream<TypingStartEvent> onTypingStart;

  /// Fired when the client sees a channel update its webhooks.
  _EventStream<WebhooksUpdateEvent> onWebhooksUpdate;

  /// Fired when the client sees a user update their presence.
  _EventStream<PresenceUpdateEvent> onPresenceUpdate;

  // Internal methods

  Future _getGateway() async {
    final response = await (api + "gateway").get();
    return json.decode(await response.readAsString())["url"];
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
    onMemberAdded = createEvent();
    onMemberRemoved = createEvent();

    onMemberBanned = createEvent();
    onMemberUnbanned = createEvent();

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
    final encoded = base64.encode(bytes);
    return "data:image/$headerType;base64,$encoded";
  }


  // External methods

  /// Modify the client's user. If you pass [avatar], you must pass [avatarFileType] or it will default to `jpg`.
  Future modify({String username, File avatar, String avatarFileType = "jpg"}) async {
    final query = {};

    if (username != null) query["username"] = username;
    if (avatar != null) query["avatar"] = await _avatarData(avatar, avatarFileType);

    final response = await (api + "users" + "@me").patch(query);
    return User._fromMap(json.decode(await response.readAsString()), this);
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
    return Channel._fromMap(json.decode(await response.readAsString()), this);
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
      "status": Game.statusesInverse[status],
      "afk": afk,
      "game": game?._toMap(),
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
		Packet packet = new Packet(opcode: 2, seq: _lastSeq, data: {
      "token": token,
      "properties": {
        "\$os": "windows",
        "\$browser": "dartsicord",
        "\$device": "dartsicord"
      },
      //"shard": shard != null ? [shard, shardCount] : null,
      "compress": false,
      "large_threshold": 250
    });
		if (shard != null)
			packet.data["shard"] = [shard, shardCount];

		_socket.add(packet.toString());
  }

  Future<Null> _establishConnection(String token, {TokenType tokenType = TokenType.bot, bool reconnecting = false}) async {
    _closed = false;

    this.token = token;
    this.tokenType = tokenType;

    final gateway = await _getGateway();
    _socket = await WebSocket.connect(gateway + "?v=6&encoding=json");

    _socket.listen((payloadRaw) async {
      final payload = json.decode(payloadRaw);
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
            if (_websocketEvents.containsKey(event)) await _websocketEvents[event](packet);
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