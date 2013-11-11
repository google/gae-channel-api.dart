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

(function() {
  function send(type, detail) {
    var evt = document.createEvent("CustomEvent");
    evt.initCustomEvent(type, false, false, JSON.stringify(detail));
    window.dispatchEvent(evt);
  }

  var sockets = {};
  
  window.addEventListener('_open_channel', function(e) {
    var token = e.detail;
    var channel = new goog.appengine.Channel(token);
    sockets[token] = channel.open({
      onmessage: function(m) {
        send('_channel_message', {'token': token, 'message': m.data});
      },
      
      onerror: function(e) {
        send('_channel_error', {'token': token, 'code': e.code, 'description': e.description});
      },
      
      onopen: function() {
        send('_channel_open', {'token': token});
      },
      
      onclose: function() {
        send('_channel_close', {'token': token});
      },
    });
  });
  
  window.addEventListener('_close_channel', function(e) {
    var token = e.detail;
    sockets[token].close();
    delete sockets[token];
  });
})();
