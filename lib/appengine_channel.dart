// Copyright 2012 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library appengine_channel;

import 'dart:html';
import 'dart:convert' show JSON;

const String _openChannel = '_open_channel';
const String _closeChannel = '_close_channel';
const String _channelOpen = '_channel_open';
const String _channelClose = '_channel_close';
const String _channelMessage = '_channel_message';
const String _channelError = '_channel_error';

// Map token->Socket for all open Sockets
Map<String, Socket> _sockets;

/*
 * Subscribes to a custom event on the window object.
 * The event's detail field is a Map with a 'token' field which is used to
 * lookup the correct Socket to pass to the handler.
 */
void _subscribe(String type,
    void handler(Socket socket, Map<String, Object> detail)) {
  window.on[type].listen((CustomEvent e) {
    Map<String, Object> detail = JSON.decode(e.detail);
    String token = detail['token'];
    Socket socket = _sockets[token];
    if ((socket != null) && (socket.onMessage != null)) {
      handler(socket, detail);
    }
  });
}

void _send(String type, String data) {
  CustomEvent event = new CustomEvent(type, canBubble: false, cancelable: false,
      detail: data);
  window.dispatchEvent(event);
}

_setup() {
  if (_sockets != null) {
    return;
  }
  _sockets = new Map<String, Socket>();
  _subscribe(_channelOpen, (s, _) => s.onOpen());
  _subscribe(_channelClose, (s, _) => s.onClose());
  _subscribe(_channelMessage, (s, d) => s.onMessage(d['message']));
  _subscribe(_channelError, (s, d) => s.onError(d['code'], d['description']));
}

/**
 * Create a channel object using the token returned by the createChannel() call
 * on the server.
 */
class Channel {
  final String token;

  Channel(this.token);

  /**
   * Open a socket on this channel.
   *
   * If the token specified during channel creation is invalid or expired then
   * the onerror and onclose callbacks will be called. The code field for the
   * error object will be 401 (Unauthorized) and the description field will be
   * 'Invalid+token.' or 'Token+timed+out.' respectively. The onerror callback
   * is also called asynchronously whenever the token for the channel expires.
   * An onerror call is always followed by an onclose call and the channel
   * object will have to be recreated after this event.
   */
  Socket open() {
    _setup();
    _send(_openChannel, token);
    Socket socket = new Socket._(token);
    _sockets[token] = socket;
    return socket;
  }
}

/** Callback for onOpen and onClose. */
typedef void Handler();

/** Callback for onMessage. */
typedef void MessageHandler(String message);

/** Callback for onError */
typedef void ErrorHandler(String code, String description);


class Socket {
  final String _token;

  Socket._(this._token);

  /**
   * Close the socket. The socket cannot be used again after calling close;
   * the server must create a new socket.
   */
  void close(void handler()) {
    _send(_closeChannel, _token);
    _sockets.remove(_token);
  }

  /**
   * Set this to a function called when the socket is ready to receive messages.
   */
  Handler onOpen;

  /**
   * Set this to a function called when the socket receives a message. The
   * function is passed one parameter: [message], which is the string passed to
   * the send_message method on the server.
   */
  MessageHandler onMessage;

  /**
   * Set this property to a function called when an error occurs on the socket.
   * The function is passed two parameters: [description] and [code]. The
   * description parameter is a description of the error and the code parameter
   * is an HTTP error code indicating the error.
   */
  ErrorHandler onError;

  /**
   * Set this property to a function that called when the socket is closed.
   * When the socket is closed, it cannot be reopened. Use the open() method on
   * a [Channel] object to create a new socket.
   */
  Handler onClose;
}
