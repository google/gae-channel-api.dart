gae-channel-api
===============

App Engine Channel API for Dart

Overview
========

Google App Engine provides a JavaScript library for receiving push messages sent
via the App Engine Channel API. gae-channel-api is a convenient Dart wrapper
around the Channel API so that you can receive channel messages in Dart
applications.

Please see the Channel API Docs for the official documentation:

  * https://developers.google.com/appengine/docs/java/channel/
  * https://developers.google.com/appengine/docs/python/channel/

Status
======

This library was built before decent JS-interop capabilities existed in Dart,
and before Futures and Streams were used in dart:io, so it's a bit behind the
state-of-the-art. The current version has been updated to work with Dart 1.0
and the next version will use dart:js and update the API to be more idomatic.

If you don't want to break on the next update, please pin the version to
`'>=0.2.0<0.3.0'` in your pubspec.

How To Use
==========

You will need to include the following script tag to load the JavaScript client:

    <script type="text/javascript" src="/_ah/channel/jsapi"></script>

And this script tag to load the JavaScript adapter:

    <script type="text/javascript" src="/channel-dart.js"></script>

Adjust the path to match where you serve the file from.

In your Dart code, import the channel library:

    import 'packages:channel/channel.dart';

Once you retrieve a token from your app, usually during the initial page load,
or in a HttpRequest, you can create a Channel instance, and from that a Socket
that you can register onOpen, onClose, onMessage, and onError handlers on.

    openChannel(String token) {
      Channel channel = new Channel(token);
      Socket socket = channel.open()
        ..onOpen = (() => print("open"))
        ..onClose = (() => print("close"))
        ..onMessage = ((m) => print("message: $m"))
        ..onError = ((code, desc) => print("error: $code $desc"));
    }

The Dart library follows the JavaScript API fairly closely and so it doesn't use
Futures or Streams. A pending update will change the API to the use Futures and
Streams.

This code has only had limited testing on the latest Chrome. Please report any
errors you find in the issue tracker.
