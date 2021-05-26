import 'package:flutter_test/flutter_test.dart';

import 'package:seq_logger/seq_logger.dart';

void main() {
  var myLog = SeqLogger();
  group('Endpoint', () {
    test('endpoint https', () {
      myLog.protocol = 'https';
      expect(myLog.endPointURI,'https://127.0.0.1:5341/api/events/raw?clef');
    });
    test('endpoint port', () {
      myLog.port = '3000';
      expect(myLog.endPointURI,'https://127.0.0.1:3000/api/events/raw?clef');
    });
    test('endpoint host', () {
      myLog.host = 'seq.example.com';
      expect(myLog.endPointURI,'https://seq.example.com:3000/api/events/raw?clef');
    });
    test('endpoint http', () {
      myLog.protocol = 'http';
      expect(myLog.endPointURI,'http://seq.example.com:3000/api/events/raw?clef');
    });
  });
  group('Error Levels', () {
    test('add custom level', () {
      myLog.setLevel('Wookie', 2.5);
      expect(myLog.levelValue('Wookie'), 2.5);
    });
    test('custom level default value', () {
      expect(myLog.levelValue('Luke'), 1.0);
    });
    test('remove level', () {
      myLog.unsetLevel('Wookie');
      expect(myLog.levelValue('Wookie'), 1.0);
    });
  });
}

