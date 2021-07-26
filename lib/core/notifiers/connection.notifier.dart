import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/core/libraries/services.dart';

class ConnectionNotifier with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();

  bool _isOnline = false;
  bool get isOnline => _isOnline;
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
    } on PlatformException catch (platformException) {
      await logger.file(LogTypeTag.ERROR,
          'PlatformException : ' + platformException.message.toString());
    } catch (e) {
      await logger.file(LogTypeTag.ERROR, e.toString());
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
    } on SocketException catch (socketException) {
      await logger.file(LogTypeTag.ERROR,
          'SocketException : ' + socketException.message.toString());
      return false;
    } catch (e) {
      await logger.file(LogTypeTag.ERROR, e.toString());
      return false;
    }
  }
}