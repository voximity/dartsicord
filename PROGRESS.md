# Library progress

Here lies a checklist of the events/methods that Dartsicord is capable of.
If something is missing, please let me know or contribute to this file.

\* This method/event has been considered to be partially or completely useless for implementation.

## WebSocket Events

- [x] Hello
- [x] Ready
- [x] Resumed
- [x] Invalid Session
- [x] Channel Create
- [x] Channel Update
- [x] Channel Delete
- [x] Channel Pins Update
- [x] Guild Create
- [x] Guild Update
- [x] Guild Delete
- [x] Guild Ban Add
- [x] Guild Ban Remove
- [x] Guild Emojis Update
- [x] Guild Integrations Update
- [x] Guild Member Add
- [x] Guild Member Remove
- [x] Guild Member Update
- [ ] Guild Members Chunk
- [x] Guild Role Create
- [x] Guild Role Update
- [x] Guild Role Delete
- [x] Message Create
- [x] Message Update
- [x] Message Delete
- [ ] Message Delete Bulk
- [x] Message Reaction Add
- [x] Message Reaction Remove
- [x] Message Reaction Remove All
- [x] Presence Update
- [ ] Typing Start
- [ ] User Update
- [ ] Voice State Update
- [ ] Voice Server Update
- [x] Webhooks Update

## REST Methods

### Audit Log

- [ ] Get Guild Audit Log \*

### Channel

- [x] Get Channel
- [x] Modify Channel
- [x] Delete/Close Channel
- [x] Get Channel Messages
- [x] Get Channel Message
- [x] Create Message
- [x] Create Reaction
- [x] Delete Own Reaction
- [x] Delete User Reaction
- [x] Get Reactions
- [x] Delete All Reactions
- [x] Edit Message
- [x] Delete Message
- [x] Bulk Delete Messages
- [ ] Edit Channel Permissions
- [x] Get Channel Invites
- [x] Create Channel Invite
- [ ] Delete Channel Permission
- [x] Trigger Typing Indicator
- [x] Get Pinned Messages
- [x] Add Pinned Channel Message
- [x] Delete Pinned Channel Message
- [ ] Group DM Add Recipient \*
- [ ] Group DM Remove Recipient \*

### Emoji

- [x] List Guild Emojis
- [ ] Get Guild Emoji
- [x] Create Guild Emoji
- [x] Modify Guild Emoji
- [x] Delete Guild Emoji

### Guild

- [ ] Create Guild
- [x] Get Guild
- [ ] Modify Guild
- [ ] Delete Guild
- [x] Get Guild Channels
- [ ] Create Guild Channel
- [ ] Modify Guild Channel Positions
- [x] Get Guild Member
- [ ] List Guild Members \*
- [ ] Add Guild Member
- [ ] Modify Guild Member
- [ ] Modify Current User's Nick
- [x] Add Guild Member Role
- [x] Remove Guild Member Role
- [x] Remove Guild Member
- [x] Get Guild Bans
- [x] Create Guild Ban
- [x] Remove Guild Ban
- [x] Get Guild Roles
- [x] Create Guild Role
- [ ] Modify Guild Role Positions
- [ ] Modify Guild Role
- [ ] Delete Guild Role
- [ ] Get Guild Prune Count
- [ ] Begin Guild Prune
- [ ] Get Guild Voice Regions
- [ ] Get Guild Invites \*
- [ ] Get Guild Integrations \*
- [ ] Create Guild Integration \*
- [ ] Modify Guild Integration \*
- [ ] Delete Guild Integration \*
- [ ] Sync Guild Integration \*
- [ ] Get Guild Embed
- [ ] Modify Guild Embed

### Invite

- [ ] Get Invite \*
- [x] Delete Invite
- [x] Accept Invite

### User

- [x] Get Current User
- [x] Get User
- [x] Modify Current User
- [x] Get Current User Guilds
- [x] Leave Guild
- [ ] Get User DMs
- [x] Create DM
- [ ] Create Group DM
- [ ] Get User Connections

### Voice

- [ ] Implemented
- [ ] List Voice Regions

### Webhook

- [x] Create Webhook
- [x] Get Channel Webhooks
- [ ] Get Guild Webhooks \*
- [ ] Get Webhook \*
- [ ] Get Webhook with Token \*
- [x] Modify Webhook
- [ ] Modify Webhook with Token \*
- [x] Delete Webhook
- [ ] Delete Webhook with Token \*
- [x] Execute Webhook
- [ ] Execute Slack-Compatible Webhook \*
- [ ] Execute GitHub-Compatible Webhook \*