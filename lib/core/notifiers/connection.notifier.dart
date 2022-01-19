// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/services.dart';

class ConnectionNotifier with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  /// Will start monitoring the user network connection making
  /// sure to notify any connection changes.
  Future<void> startMonitoring() async {
    await initConnectivity();
    _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        _isOnline = false;
        notifyListeners();
      } else {
        await _updateConnectionStatus().then((bool isConnected) {
          _isOnline = isConnected;
          notifyListeners();
        });
      }
    });
  }

  Future<void> initConnectivity() async {
    try {
      ConnectivityResult status = await _connectivity.checkConnectivity();
      if (status == ConnectivityResult.none) {
        _isOnline = false;
        notifyListeners();
      } else {
        _isOnline = true;
        notifyListeners();
      }
    } on PlatformException catch (_) {
      await logger.file(
          LogTypeTag.error, 'PlatformException: $_');
    } catch (e) {
      await logger.file(LogTypeTag.error, e.toString());
    }
  }

  Future<bool> _updateConnectionStatus() async {
    try {
      List<InternetAddress> result =
          await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      await logger.file(LogTypeTag.error, 'SocketException: $_');
      return false;
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to update connection status $_',
          stackTraces: s);
      return false;
    }
  }
}
