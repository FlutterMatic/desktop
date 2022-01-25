// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/libraries/services.dart';

class NotificationsNotifier with ChangeNotifier {
  final List<NotificationObject> _notifications = <NotificationObject>[];
  List<NotificationObject> get notifications => _notifications;

  /// Will start monitoring the user network connection making
  /// sure to notify any connection changes.
  void newNotification(NotificationObject notificationObject) {
    // Make sure that this id doesn't already exist.
    bool _idExists = false;

    for (NotificationObject notification in _notifications) {
      if (notification.id == notificationObject.id) {
        _idExists = true;
        break;
      }
    }

    if (_idExists) {
      logger.file(LogTypeTag.error,
          'Notification id already exists. Can\'t add a duplicated notification id: ${notificationObject.id}');
      assert(false,
          'Notification id already exists. Can\'t add a duplicated notification id: ${notificationObject.id}');
      return;
    }

    if (!_notifications.contains(notificationObject)) {
      _notifications.add(
        NotificationObject(
          notificationObject.id,
          title: notificationObject.title,
          message: notificationObject.message,
          onPressed: notificationObject.onPressed,
          timestamp: DateTime.now(), // Will add the current time to the
          // notification. This can be used to show the time.
        ),
      );
      notifyListeners();

      logger.file(LogTypeTag.info,
          'New notification: ${notificationObject.id} - ${notificationObject.title} - ${notificationObject.message}');
    }
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere(
        (NotificationObject notification) => notification.id == notificationId);
    notifyListeners();
    logger.file(LogTypeTag.info, 'Removed notification: $notificationId');
  }

  void clearNotifications() {
    logger.file(LogTypeTag.info,
        'Notifications cleared: ${_notifications.length} notifications');
    _notifications.clear();
    notifyListeners();
  }
}

class NotificationObject {
  final String id;
  final String title;
  final String message;
  final Function()? onPressed;
  final DateTime? timestamp;

  const NotificationObject(
    this.id, {
    required this.title,
    required this.message,
    required this.onPressed,
    this.timestamp,
  });
}
