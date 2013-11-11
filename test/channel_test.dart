import 'dart:html';
import 'package:appengine_channel/appengine_channel.dart';
import 'package:unittest/unittest.dart';
import 'package:js/js.dart' as js;

main() {
  test("onMessage", () {
    var channel = new Channel("atoken");
    var socket = channel.open();
    socket.onMessage = expectAsync1((m) {
      expect(m, 'a_message');
    });
    js.scoped(() {
      var channel = js.context.channels['atoken'];
      var data = js.map({'data':'a_message'});
      channel.socket.config.onmessage(data);
    });
  });
}
