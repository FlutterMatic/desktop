// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/core/notifiers/notifications.notifier.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/utils/time_ago.dart';

class NotificationTile extends StatefulWidget {
  final Function() onDelete;
  final NotificationObject notification;

  const NotificationTile({
    Key? key,
    required this.onDelete,
    required this.notification,
  }) : super(key: key);

  @override
  _NotificationTileState createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: widget.notification.onPressed == null
            ? null
            : () {
                widget.notification.onPressed!();
                logger.file(LogTypeTag.info,
                    'Notification tapped: ${widget.notification.id}');
              },
        child: RoundContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.notification.title,
                        style: const TextStyle(fontSize: 16)),
                    VSeparators.xSmall(),
                    Text(
                      widget.notification.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (widget.notification.timestamp != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          getTimeAgo(widget.notification.timestamp!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
              if (_isHovering) ...<Widget>[
                HSeparators.normal(),
                SquareButton(
                  size: 30,
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_forever,
                      color: AppTheme.errorColor, size: 15),
                  onPressed: widget.onDelete,
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
