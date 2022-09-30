// 📦 Package imports:
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/notifiers/models/payloads/general/notifications.dart';
import 'package:fluttermatic/core/services/logs.dart';

class NotificationsNotifier extends StateNotifier<void> {
  final Reader read;

  NotificationsNotifier(this.read) : super(null);

  static final List<NotificationObject> _notifications = [];

  UnmodifiableListView get notifications =>
      UnmodifiableListView(_notifications);

  /// Adds a new notification and notifies the state about it. This will also
  /// log an error if the notification id already exists. Make sure you get
  /// a reliable source to get a unique id. The best way you could achieve this
  /// is by using the [Timeline] utilities provided from the `dart:developer`
  /// library.
  ///
  /// This allows you to get a unique id each time.
  Future<void> newNotification(NotificationObject notificationObject) async {
    // Make sure that this id doesn't already exist.
    bool idExists = false;

    for (NotificationObject notification in _notifications) {
      if (notification.id == notificationObject.id) {
        idExists = true;
        break;
      }
    }

    if (idExists) {
      await logger.file(LogTypeTag.error,
          'Notification id already exists. Can\'t add a duplicated notification id: ${notificationObject.id}');

      return;
    }

    _notifications.add(
      NotificationObject(
        notificationObject.id,
        title: notificationObject.title,
        message: notificationObject.message,
        onPressed: notificationObject.onPressed,
        // Will add the current time to the notification. This can be used to show the time.
        timestamp: DateTime.now(),
      ),
    );

    await logger.file(LogTypeTag.info,
        'New notification: ${notificationObject.id} - ${notificationObject.title} - ${notificationObject.message}');
  }

  /// Will remove the notification based on the notification id you provided.
  ///
  /// If no such notification exists, then this future will complete normally,
  /// with nothing being thrown.
  Future<void> removeNotification(String notificationId) async {
    _notifications.removeWhere((e) => e.id == notificationId);

    await logger.file(LogTypeTag.info, 'Removed notification: $notificationId');
  }

  /// Clears all notifications from the notification list.
  Future<void> clearNotifications() async {
    int total = _notifications.length;

    _notifications.clear();

    await logger.file(
        LogTypeTag.info, 'Notifications cleared: $total notifications');
  }
}
