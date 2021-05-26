# Seq Logger (seq_logger) for Dart/Flutter

A simple logger for [Seq](https://datalust.co/seq) which supports the standard log levels, 
custom log levels, and logging via message templates. 

## Getting Started

Using Seq Logger is easy; import the package, instantiate a logger and start using.  This example uses default values
for connecting to the Seq host, the default is **ht<span>tp://127.0.0.1:5341**
```dart
import 'package:seq_logger/seq_logger.dart';

void main() {
   var myLog = SeqLogger();
   
   // By default, if level not specified, logs as INFO
   myLog.log(message: 'Nothing to see here, move along');
}
```

## Using Seq Logger

SeqLogger() is backed by a singleton controller class, so changes to connection details, custom levels, and apiKey are
preserved globally.

### Connection details
You can specify host, port, protocol.  If your Seq server requires authentication with api key,
you can add that too.

```dart
  var myLog = SeqLogger();
  myLog.host = 'seq.example.com';
  myLog.port = '8041';
  myLog.protocol = 'https';
  myLog.apiKey = 'XGQNJcDbDaXy648Ns4qn';
```

### Log Levels
Log Levels in Seq Logger are represented by double values. This allows adding 
custom log levels and inserting between other levels.  The default level for log messages and
the default minimum level is **Info**. The initial available levels and values are: 

- Trace : 0.0
- Debug : 1.0
- Info : 2.0
- Warning : 3.0
- Error : 4.0
- Fatal : 5.0

Setting the minimum level
```dart
  var myLog = SeqLogger();
  myLog.minimumLevel = 1.5;
```

Log Level keys are stored internally as first letter capitalized, the rest lower case. You
can use mixed case when referring to log levels, but in your Seq server, the log level
will be seen as first letter capitalized.  You can also remove log levels not needed anymore. 
You migh ask, **_"What happens if log level doesn't exist anymore and it is still
used in the code?"_**.  It is still valid and won't cause an error.  Its log level
value will default to 1.0 and it will still log to the server if the minimum log level
is 1 or less.

Custom Log Levels are also preserved across instatiation of SeqLogger(). Adding custom levels, query the value of a log level, removing unwanted levels:
```dart
 
  var myLog = SeqLogger();
  myLog.setLevel('NetworkIO', 1.5);
  myLog.setLevel('Critical', 5);
  print(myLog.levelValue('networkio'));
  // We don't want Warning or Networkio anymore
  myLog.unsetLevel('NetworkIO');
  myLog.unsetLevel('Warning');
```

To wrap up log levels:
- Default Log Level is **Info**
- Default minimum level is **Info**
- You can use mixed case when referring to log levels
- You can add custom levels with any double value and can insert them between other levels
- You can use a log level that has _not been defined_ or _removed_ and it will default to a value of 1.0 and will get logged
  if it satisfies the minimum log level requirement.

## Logging Messages
Use the **log** method from your SeqLogger() instance.  The simplest form is to just log a text message with default
log level _Info_, or specify the log level you want to use

```dart
  var myLog = SeqLogger();
  myLog.log(message: 'Velum, his vita.');
  myLog.log(message: 'Phasmatis manus palma.', level: 'Warning');
```

### Message Templates and User Properties
Seq server supports message templating from which properties can be extracted and queried, for more information
see https://messagetemplates.org/

To use message templates, you provide a template string which contains placeholders (_named holes_) for
the data you want to be able to query Seq about and a Map<String, dynamic> object that contains the values 
for the placeholders.  The template will be used to render a message with the values inserted into the message.  The
number of items in the Map object must match the number _named holes_.

Take this example:
```dart
  myLog.log(
      template: "Temperature is {temperature} in {scale}",
      templateValues: {'temperature': '68 degrees', 'scale': 'Fahrenheit'});
```
This message will render in Seq as `Temperature is 68 degress in Fahrenheit`.  Additionally, in Seq there will be properties
named **temperature** and **scale** with their respective values for this message allowing for log analysis based on these
properties and values. 

You can also add properties without rendering them into the message template, these are called _User Properties_ and are
added by providing a Map of the key/value pairs.
```dart
  myLog.log(
      template: "Temperature is {temperature} in {scale}",
      templateValues: {'temperature': '68 degrees', 'scale': 'Fahrenheit'},
      userProperties: {'location': 'San Jose', 'station': 14});
```
This message will also render as `Temperature is 68 degress in Fahrenheit`.  However, there will be more properties with
the message than just **temperature** and **scale**, there will also be **location** and **station** with their respective
values.  In Seq, it will appear like this:

![seq-figure-1](./seq-figure-1.png)

### Logging Objects

You can log objects as well. In the backend, this library uses json format to post to the Seq server, so the object
must be convertible to json using jsonEncode() from `dart:convert`.  If it isn't, you should provide a `.toJson()` method
on the object. 

In this example, we log an object as userProperties.
```dart
  var myLog = SeqLogger();
  Map<String, int> Ages = {'Bob':54, 'Kathy':18, 'Wente Chardonnay': 3};
  myLog.log(message: 'Age Object', userProperties: {'Ages': Ages});
```

It appears as this in Seq:

![seq-figure-4](./seq-figure-4.png)


### Classifying Log Messages

Notice the log classification `[main]![testing] =>` in the above image, this is another feature of the logger, 
you can add a _classification_ and _division_ to log messages within the scope of the SeqLogger() instance.  This
can be useful when you want to identify which messages occurred in specific code regions, classes, methods, etc.

In this example, we set a classification of _main_ to show these logs are coming from the main() function.  We set
a _division_ to sub categorize the log messages.
```dart
void main() {
  var myLog = SeqLogger(classification: 'main');
  myLog.log(message: 'Doing stuff');
  {
    var myLog = SeqLogger(classification: 'main', division: 'calculate');
    myLog.log(message: 'Doing hard work');
    var a = 3 * 3;
    myLog.log(message: 'Done with hard work');
  }
  myLog.log(message: 'Did something just happen?');
} 
```

What you get in Seq is the following.

![seq-figure-2](./seq-figure-2.png)

 

### Logging Exceptions

Lastly, you can identify a message as an exception by using the option _exception_.  Seq categorizes these
and visually renders them differently.  Typically, you would use this to log exceptions from your try/catch blocks and 
include the exception or traceback text.  You could also use this highlight the message as important.

For example:
```dart
  var myLog = SeqLogger(classification: 'main');
  myLog.log(level: 'Error', message: 'This is an exception', exception: 'Idex out of bounds!');
```
Gives:

![seq-figure-3](./seq-figure-3.png)

## Features and Bugs
Please file feature requests and bugs at the issue tracker.
