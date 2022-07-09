// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/notifiers/models/state/general/connection.dart';
import 'package:fluttermatic/core/services/logs.dart';

class ConnectionNotifier extends StateNotifier<NetworkState> {
  final Reader read;

  ConnectionNotifier(this.read) : super(NetworkState.initial());

  final Connectivity _connectivity = Connectivity();

  /// Initializes monitoring the connection state. This automatically updates
  /// the state of the connection to any context watchers when the connection
  /// status changes.
  ///
  /// This will keep running in the background even after it has returned.
  /// It's a very lightweight listener that listens to network status changes.
  Future<void> initConnectivity() async {
    try {
      ConnectivityResult status = await _connectivity.checkConnectivity();

      if (status == ConnectivityResult.none) {
        state = state.copyWith(
          isConnected: false,
        );
      } else {
        state = state.copyWith(
          isConnected: true,
        );
      }

      _startMonitoring();
      return;
    } on PlatformException catch (_, s) {
      await logger.file(LogTypeTag.error,
          'Failed to initialize connection. PlatformException: $_',
          stackTraces: s);
    } catch (_, s) {
      await logger.file(LogTypeTag.error,
          'Failed to establish initial connection: ${_.toString()}',
          stackTraces: s);
    }
  }

  /// Will start monitoring the user network connection making sure to notify
  /// any connection changes.
  void _startMonitoring() {
    _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        state = state.copyWith(
          isConnected: false,
        );

        await logger.file(
            LogTypeTag.warning, 'Lost connection. FlutterMatic is offline.');
        return;
      }

      await _getConnectionStatus().then((bool isConnected) async {
        state = state.copyWith(
          isConnected: isConnected,
        );

        if (isConnected) {
          await logger.file(
              LogTypeTag.info, 'Back online. FlutterMatic is online.');
        } else {
          await logger.file(
              LogTypeTag.warning, 'Lost connection. FlutterMatic is offline.');
        }
      });
    });
  }

  /// Makes a lookup request to google.com. If responds with a valid internet
  /// address that means we have a connection, otherwise it might be any of the
  /// following:
  /// - No connection
  /// - An error occurred.
  Future<bool> _getConnectionStatus() async {
    try {
      List<InternetAddress> result =
          await InternetAddress.lookup('www.google.com');

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
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
