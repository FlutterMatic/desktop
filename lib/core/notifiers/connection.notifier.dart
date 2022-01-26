// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';

class ConnectionNotifier with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Will start monitoring the user network connection making
  /// sure to notify any connection changes.
  Future<void> startMonitoring() async {
    _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        _isOnline = false;
        await logger.file(
            LogTypeTag.warning, 'Lost connection. FlutterMatic is offline.');
      } else {
        await _updateConnectionStatus().then((bool isConnected) async {
          _isOnline = isConnected;

          if (isConnected) {
            await logger.file(
                LogTypeTag.info, 'Back online. FlutterMatic is online.');
          } else {
            await logger.file(LogTypeTag.warning,
                'Lost connection. FlutterMatic is offline.');
          }
        });
      }

      notifyListeners();
    });
  }

  Future<void> initConnectivity() async {
    try {
      ConnectivityResult _status = await _connectivity.checkConnectivity();

      if (_status == ConnectivityResult.none) {
        _isOnline = false;
      } else {
        _isOnline = true;
      }

      notifyListeners();

      // ignore: unawaited_futures
      startMonitoring();
      return;
    } on PlatformException catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to init connection. PlatformException: $_',
          stackTraces: s);
    } catch (_, s) {
      await logger.file(LogTypeTag.error,
          'Failed to establish initial connection: ${_.toString()}',
          stackTraces: s);
    }
  }

  Future<bool> _updateConnectionStatus() async {
    try {
      List<InternetAddress> _result =
          await InternetAddress.lookup('www.google.com');

      return _result.isNotEmpty && _result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_, s) {
      await logger.file(LogTypeTag.error, 'SocketException: $_',
          stackTraces: s);
      return false;
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to update connection status $_',
          stackTraces: s);
      return false;
    }
  }
}
