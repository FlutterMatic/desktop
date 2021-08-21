import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';

class CustomProgressIndicator extends StatefulWidget {
  const CustomProgressIndicator(
      {required this.disabled,
      // required this.package,
      required this.onCancel,
      required this.progress,
      this.message,
      required this.toolName});

  /// Whether or not to disable this component.
  final bool disabled;

  // final String? package;

  /// The current progress of the installation.
  final Progress progress;
  final String? message;

  /// The function triggered when the user has requested to cancel
  /// the installation.
  final VoidCallback? onCancel;

  /// The name of the tool that is being installed so that it can show
  /// appropriate messages for each type.
  final String? toolName;

  @override
  _CustomProgressIndicatorState createState() =>
      _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadNotifier>(
      builder: (BuildContext context, DownloadNotifier downloadNotifier, _) {
        if (downloadNotifier.downloadProgress < 100) {
          return Container(
            width: 200,
            child: Column(
              children: <Widget>[
                hLoadingIndicator(
                  value: downloadNotifier.downloadProgress / 100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _color(progress: widget.progress)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('${downloadNotifier.downloadProgress.floor()}%'),
                    Text(downloadNotifier.remainingTime == 'calculating'
                        ? 'Calculating...'
                        : '${downloadNotifier.remainingTime} left'),
                  ],
                ),
              ],
            ),
          );
        } else {
          return hLoadingIndicator(
            context: context,
          );
        }
      },
    );
  }
}

// Widget progressIndicator({
//   /// Whether or not to disable this component.
//   required bool disabled,

//   /// A string telling the user how much space it will take on the disk.
//   required String objectSize,
//   String? package,

//   /// The current progress of the installation.
//   required Progress progress,

//   /// The function triggered when the user has requested to cancel
//   /// the installation.
//   required VoidCallback? onCancel,

//   /// The name of the tool that is being installed so that it can show
//   /// appropriate messages for each type.
//   required String toolName,
// }) {

// }

Color _color({Progress progress = Progress.none}) {
  // if (progress == Progress.done) {
  //   return kGreenColor;
  // } else if (progress == Progress.failed) {
  //   return AppTheme.errorColor;
  // } else {
  return AppTheme.primaryColor;
  // }
}

String _getActionName(Progress progress) {
  if (progress == Progress.done) {
    return 'Downloaded';
  } else if (progress == Progress.extracting) {
    return 'Extracting';
  } else if (progress == Progress.downloading || progress == Progress.started) {
    return 'Downloading';
  } else {
    return '';
  }
}

Widget _actionButton(
  BuildContext context, {
  required String buttonName,
  required Widget icon,
  required Color color,
  required Function() onPressed,
}) {
  return Tooltip(
    message: buttonName,
    child: Container(
      height: 35,
      width: 35,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.4),
      ),
      child: IconButton(onPressed: onPressed, icon: icon, splashRadius: 20),
    ),
  );
}
