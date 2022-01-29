// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/notifiers/notifications.notifier.dart';
import 'package:fluttermatic/meta/views/dialogs/notifications/notification_tile.dart';

class NotificationViewDialog extends StatefulWidget {
  const NotificationViewDialog({Key? key}) : super(key: key);

  @override
  State<NotificationViewDialog> createState() => _NotificationViewDialogState();
}

class _NotificationViewDialogState extends State<NotificationViewDialog> {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          DialogHeader(
            title: 'Notifications',
            leading: context.read<NotificationsNotifier>().notifications.isEmpty
                ? null
                : SquareButton(
                    color: Colors.transparent,
                    tooltip: 'Clear all',
                    icon: const Icon(Icons.clear_all_rounded, size: 20),
                    onPressed: () {
                      // Ask to confirm clear all
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarTile(
                          context,
                          'Are you sure you want to clear all notifications?',
                          action: snackBarAction(
                            text: 'Clear all',
                            onPressed: () {
                              context
                                  .read<NotificationsNotifier>()
                                  .clearNotifications();
                              Navigator.pop(context);
                            },
                          ),
                          type: SnackBarType.warning,
                        ),
                      );
                    },
                  ),
          ),
          // If there are no notifications, show a different layout with a
          // message.
          if (context.read<NotificationsNotifier>().notifications.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SvgPicture.asset(Assets.done),
                    VSeparators.normal(),
                    const Text('No notifications'),
                    VSeparators.small(),
                    const Text(
                      'You have no new notifications, cheers!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                itemCount:
                    context.read<NotificationsNotifier>().notifications.length,
                shrinkWrap: true,
                itemBuilder: (_, int i) {
                  bool _isLast = i ==
                      context
                              .read<NotificationsNotifier>()
                              .notifications
                              .length -
                          1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: _isLast ? 0 : 10),
                    child: NotificationTile(
                      notification: context
                          .read<NotificationsNotifier>()
                          .notifications[i],
                      onDelete: () {
                        context
                            .read<NotificationsNotifier>()
                            .removeNotification(context
                                .read<NotificationsNotifier>()
                                .notifications[i]
                                .id);
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
