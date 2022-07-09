// 🌎 Project imports:
import 'package:fluttermatic/core/notifiers/models/payloads/general/notifications.dart';

class NotificationsState {
  final List<NotificationObject> notifications;

  const NotificationsState({
    this.notifications = const <NotificationObject>[],
  });

  factory NotificationsState.initial() => const NotificationsState();

  // Add a notification
  void addNotification(NotificationObject notification) {
    notifications.add(notification);
  }

  // Remove a notification
  void removeNotification(String notificationId) {
    notifications.removeWhere((notification) {
      return notification.id == notificationId;
    });
  }

  // Clear all notifications
  void clearNotifications() {
    notifications.clear();
  }
}
