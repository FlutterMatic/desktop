// 🐦 Flutter imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/core/notifiers/models/payloads/general/notifications.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/notifications.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final Reader read;

  NotificationsNotifier(this.read) : super(NotificationsState.initial());

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

    for (NotificationObject notification in state.notifications) {
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

    state.addNotification(
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
    state.removeNotification(notificationId);

    await logger.file(LogTypeTag.info, 'Removed notification: $notificationId');
  }

  /// Clears all notifications from the notification list.
  Future<void> clearNotifications() async {
    state.clearNotifications();

    await logger.file(LogTypeTag.info,
        'Notifications cleared: ${state.notifications.length} notifications');
  }
}
