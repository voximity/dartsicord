# Changelog

## 0.1.1+2

Fix bulk delete messages issue.

## 0.1.1

12 Mar 2018

This project is not abandoned, I just haven't seen a reason to update it lately. In this update, I focused on touching up the internals of the library quite a lot. More of the internally recognized fields and methods are now private because I've switched to using `part` and `part of`. It's becoming unsupported but it works a lot better in my case.

- Move all events to an internal websocket event map
- Switch to `part` and `part of`
- Add embed builder methods
- Finish `client.modify` avatar features
- Make many existing constructors/methods internal
- Add more tests

## 0.1.0+1,2

Fix critical heartbeat formatting issue.

## 0.1.0

25 Dec 2017 (Merry Christmas again)

Woohoo! 0.1.0 is the first major pre-1.0 version. This version attempts to complete all events, most REST methods, and adds some missing features I've forgotten to add in the past. I've also reworked the networking system (again), and made everything a bit more user friendly. In some coming updates, I'll be going through documentation and making everything very specific and easy to use.

- Add author support
- Add channel overwrites
- Rework permission system
- Rework Route system
- Rework a few update events
- Finish channel events and methods
- Finish client events

## 0.0.13

25 Dec 2017 (Merry Christmas)

In 0.0.13, I added some more core concepts, such as invites, reactions, and more. I've added more events and methods as well. Additionally, I've made a lot of fixes to untested features. Probably the most exciting of all is the new example, `giveaway`. Check out the example directory for the new example. Comments are included to show how the library works and processes reactions. I plan to soon have most, if not all, events/methods required implemented. From there, I will be adding more unit tests. If you think this is a cool library, tell some of your friends. I need others to help contribute and find bugs!

- Add reaction support
- Add invite support
- Many fixes (like a lot of fixes)
- internals -> networking

## 0.0.12

24 Dec 2017

This update focuses on unit testing! (yay) I'm using the generic test library for Dart allowing for simple, straight-forward unit testing. You can find the tests in the test directory. They have been set up to execute often on Travis-CI, so you'll notice a new build badge on the README. Additionally, I've also implemented Resuming, a vital feature for maintaining a connection with the WS.

- Add test directory
- Add a message test
- Add get message from a channel
- connect -> _establishConnection
- _reconnect -> _establishConnection with positional parameter reconnect: true
- Add client.disconnect
- Use Travis for building/testing (.travis.yml)

## 0.0.11

24 Dec 2017

This update focuses on more UX changes. I've added an in-depth PROGRESS file showing the progress of the library with its events and methods. I've also focused on completely implementing Websockets as well as trying to make some cacheing systems more efficient. I've also renamed the resources directory to objects because some of the objects were not considered resources. Additionally, I've renamed DiscordObject to simply Resource, as a resource is any object that has a Snowflake. Typically, these objects could be referred to as instantiated classes, while non-resource objects such as Game could be simply referred to as a struct.

- Abide to more linter preferences
- Add Webhook support
- Rename resources to objects
- Rename DiscordObject to Resource
- Add Webhook Update event
- Add Presence Update event
- Add PROGRESS.md indicating library progress

## 0.0.10

23 Dec 2017

This update focuses mostly on user experience rather than new features. I have recently been on vacation, so I apologize for the few updates! If you haven't already noticed, I'm going to start adding more detail into the CHANGELOG like this short paragraph as well as a date in which the update was released. Additionally, I'm planning on making dartsicord a little more serious than I planned it to be.

- Abide to more linter preferences
- Organize code a bit better
- Add more guild methods
- Add more channel methods
- Add more message methods
- Add more documentation to most things that don't already have documentation

## 0.0.9

- More guild events
- Kind of just a test update from a different machine

## 0.0.8

- Add status updating support
- Add game class
- Add enums for status and activity types
- Change linter preferences and abide by them (for the most part)

## 0.0.7

- Add a lot more events
- Move events from event.dart to events directory
- Fix up some fromDynamic to _fromMap parameter types
- More REST methods
- More work on Snowflake usage

## 0.0.6

- Replace int-based id with Snowflake class
- Add Emoji class
- Add Emoji events
- Add Emoji methods
- Add User banned and unbanned events
- Use localEndpoint instead of endpoint + id

## 0.0.5

- Add more guild events
- More documentation for events and stuff
- Move around some client methods for internal organization

## 0.0.4

- Rehaul events
- fromDynamic is now _fromMap
- More fixes

## 0.0.3

- More documentation
- Fixes

## 0.0.1-0.0.2

- See GitHub