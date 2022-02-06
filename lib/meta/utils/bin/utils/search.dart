// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';

class AppGlobalSearch {
  // static final PubClient _pubClient = PubClient();

  static DateTime? _lastIndexTime;

  static Future<List<AppSearchResult>> searchIsolate(List<dynamic> data) async {
    // SendPort _port = data[0];
    // String _query = data[1];
    // String _path = data[2];

    try {
      // We will update the indexes if last search time is more than specified
      // time
      DateTime _current = _lastIndexTime ??
          DateTime.now().subtract(const Duration(minutes: 10));

      Duration _expireTimeout = const Duration(minutes: 10);

      if (_lastIndexTime == null ||
          DateTime.now().difference(_current) >= _expireTimeout) {
        // TODO: Updated indices

        // Now we updated the index, we will update the last index search
        _lastIndexTime = DateTime.now();
      }

      return <AppSearchResult>[];
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to perform app global search: $_',
          stackTraces: s);

      return <AppSearchResult>[];
    }
  }
}

class AppSearchResult {
  final String title;
  final String subtitle;
  final Widget content;

  const AppSearchResult({
    required this.title,
    required this.subtitle,
    required this.content,
  });
}
