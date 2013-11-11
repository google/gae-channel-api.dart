import 'dart:js';
import 'package:appengine_channel/appengine_channel.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

main() {
  useHtmlEnhancedConfiguration();

  group('Channel', () {
    test('onMessage', () {
      var channel = new Channel('atoken');
      var socket = channel.open();
      socket.onMessage = expectAsync1((m) {
        expect(m, 'a_message');
      });

      var jsChannel = context['channels']['atoken'];
      var data = new JsObject.jsify({'data':'a_message'});
      jsChannel['socket']['config'].callMethod('onmessage', [data]);
    });
  });
}
