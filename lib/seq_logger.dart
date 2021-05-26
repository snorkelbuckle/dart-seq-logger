library seq_logger;

import 'dart:convert';
import 'package:dio/dio.dart';

class _SeqController {
  static final _SeqController _instance = _SeqController._internal();

  String protocol = 'http';
  String host = '127.0.0.1';
  String port = '5341';
  String? apiKey;


  bool printErrors = false;

  Map<String, double> _logLevels = {
    'Trace': 0.0,
    'Debug': 1.0,
    'Info': 2.0,
    'Warning': 3.0,
    'Error': 4.0,
    'Fatal': 5.0
  };


  double minimumLevel = 2.0;

  factory _SeqController() {
    return _instance;
  }

  _SeqController._internal();

  String endpointURI() {
    var uri = '${this.protocol}://${this.host}:${this.port}/api/events/raw?clef';
    if (this.apiKey != null) {
      uri = '$uri&apiKey=${this.apiKey}';
    }
    return uri;
  }

  Future<bool> _sendMessage(String compactJson) async {
    var dio = Dio();
    try {
      await dio.post(endpointURI(), data: compactJson);
    } on DioError catch (e) {
      if ((e.response != null) && (printErrors == true)) {
        print('Endpoint Error: ${e.response!.statusCode} : ${e.response!.statusMessage}');
        print('Request ${e.response!.realUri}');
        print('Data: $compactJson');
        return false;
      }
    } catch (e) {
      if (printErrors == true) {
        print('Unknown Error: $e');
      }
      return false;
    }
    return true;
  }


  double? levelValue(String level) {
    if (_logLevels.containsKey(level)) {
      return _logLevels[level];
    }
    else {
      return 1.0;
    }
  }


  setLevel(String level, double value) {
    _logLevels['${level[0].toUpperCase()}${level.substring(1).toLowerCase()}'] = value;
  }


  unsetLevel(String level) {
    if (_logLevels.containsKey('${level[0].toUpperCase()}${level.substring(1).toLowerCase()}'))
      _logLevels.remove('${level[0].toUpperCase()}${level.substring(1).toLowerCase()}');
  }
}

/// A simple Seq logger which supports the standard log levels, custom log levels,
/// and logging via message templates.

class SeqLogger {
  late _SeqController _logger;
  String? classification;
  String? division;

  SeqLogger({String? classification, String? division}) {
    this._logger = _SeqController();

    if (classification != null) this.classification = classification;
    if (division != null) this.division = division;
  }

  /// Log the structured message to the Seq server
  void log({String? message, String level = 'Info', String? template, Map<String,
      dynamic>? templateValues, Map? userProperties, String? exception}) => this._sendMessage(
        '${level[0].toUpperCase()}${level.substring(1).toLowerCase()}', message, template, templateValues, userProperties, exception);

  /// The constructed endpoint URI
  String get endPointURI => _SeqController().endpointURI();

  /// The protocol to use when connecting to the Seq server, use 'http' or 'https'
  String get protocol => _SeqController().protocol;

  /// TCP port the Seq server is listening on for ingestion
  String get port => _SeqController().port;

  /// The host of the Seq server, use IP address or Host name
  String get host => _SeqController().host;

  /// If an api key is required to connect to the Seq server, then specify it here.  If an api key not
  /// required, then set at null
  String? get apiKey => _SeqController().apiKey;

  /// The minimum log level to be logged
  double get minimumLevel => _SeqController().minimumLevel;

  /// The value of the given log level
  double? levelValue(String level) => _SeqController().levelValue(level);

  /// Add a custom log level or modify an existing log level.  You can even modify the pre-packaged
  /// log levels: Trace, Debug, Info, Warning, Error, and Fatal.
  void setLevel(String level, double value) => _SeqController().setLevel(level, value);

  /// Removes a log level.  Can even remove the pre-packaged log levels.
  void unsetLevel(String level) => _SeqController().unsetLevel(level);

  set protocol(String protocol) {
    _SeqController().protocol = protocol;
  }

  set port(String port) {
    _SeqController().port = port;
  }

  set host(String host) {
    _SeqController().host = host;
  }

  set apiKey(String? apiKey) {
    _SeqController().apiKey = apiKey;
  }

  /// If true, then print any errors to the console that are caught while trying to log a message to the Seq server.
  /// SeqLogger uses the Dio package (https://pub.dev/packages/dio) to make the underlying connections.  SeqLogger by default silently
  /// ignores transport errors.  Enabling this will allow to see errors reported by Dio.
  set toggleConsoleErrors(bool toggle) {
    _SeqController().printErrors = toggle;
  }

  set minimumLevel(double min) {
    _SeqController().minimumLevel = min;
  }

  Future<bool> _sendMessage(String level, String? message, String? template, Map<String, dynamic>? templateValues, Map? userProperties,
      String? exception) async {
    var levelValue = _logger.levelValue(level);
    if (levelValue != null) {
      if (levelValue >= _logger.minimumLevel) {
        var msg = _createJsonMessage(level, message, template, templateValues, userProperties, exception);
        return await this._logger._sendMessage(msg);
      }
    }
    return false;
  }

  String _createJsonMessage(String logLevel, String? message, String? template, Map<String, dynamic>? templateValues, Map? userProperties,
      String? exception) {
    String? setInfo;
    if (classification != null) {
      setInfo = '[$classification]';
    }
    if (division != null) {
      setInfo = '$setInfo![$division]';
    }

    var _jsonMsg = new Map();

    _jsonMsg['@t'] = DateTime.now().toIso8601String();
    _jsonMsg['@l'] = logLevel;

    if (message != null) {
      if (setInfo != null) {
        _jsonMsg['@m'] = '$setInfo => $message';
      }
      else
        _jsonMsg['@m'] = message;
    }

    if (template != null) {
      if (setInfo != null) {
        _jsonMsg['@mt'] = '$setInfo => $template';
      }
      else
        _jsonMsg['@mt'] = template;
      if (templateValues != null) {
        templateValues.forEach((key, value) {
          _jsonMsg[key] = value;
        });
      }
    }

    if (userProperties != null) {
      userProperties.forEach((key, value) {
        _jsonMsg['$key'] = value;
      });
    }

    if (exception != null) {
      _jsonMsg['@x'] = exception;
    }

    var json = jsonEncode(_jsonMsg);
    return json;
  }
}
