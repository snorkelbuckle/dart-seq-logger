import 'package:seq_logger/seq_logger.dart';
import 'package:flutter_lorem/flutter_lorem.dart';

// void main() {
//   var myLog = SeqLogger(classification: 'main', division: 'testing');
//   myLog.setLevel('WOOkie', 2);
//   myLog.apiKey = 'XGQNJcXbDGXy648Ns2qn';
//   myLog.toggleConsoleErrors = true;
//   myLog.minimumLevel = 1;
//   {
//     var myLog = SeqLogger(classification: 'main', division: 'other');
//     myLog.log(message: 'Doing Stuff');
//   }
//   // myLog.log(message: lorem(paragraphs: 1, words: 3));
//   // myLog.log(level: 'wooKie', message: lorem(paragraphs: 1, words: 3));
//   // SeqMessenger().unsetLevel('wookie');
//   // try {
//   //    var a = 0;
//   //    throw Exception('Not Happy');
//   // }
//   // catch (e) {
//   //    myLog.log(message: 'Caught Exception', exception: e.toString());
//   // }
//   // myLog.log(level: 'wooKie', message: 'Final Wookie');
//   myLog.log(message: 'Nothing to see here, move along');
//   myLog.log(
//       template: "Temperature is {temperature} in {scale}",
//       templateValues: {'temperature': '68 degrees', 'scale': 'Fahrenheit'},
//       userProperties: {'location': 'San Jose', 'station': 14});
//
//
// }



void main() {
  var myLog = SeqLogger(classification: 'main', division: 'testing');
  myLog.log(message: 'Doing stuff');
  {
    var myLog = SeqLogger(classification: 'main', division: 'calculate');
    myLog.log(message: 'Doing hard work');
    var a = 3 * 3;
    myLog.log(message: 'Done with hard work');
  }
  myLog.log(message: 'Did something just happen?');

  myLog.log(level: 'Error', message: 'This is an exception', exception: 'Idex out of bounds!');

  Map<String, int> Ages = {'Bob':54, 'Kathy':18, 'Wente Chardonnay': 3};
  myLog.log(message: 'Age Object', userProperties: {'Ages': Ages});
}
