import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';

Widget installProgressIndicator({
  /// Whether or not to disable this component.
  required bool disabled,

  /// A string telling the user how much space it will take on the disk.
  required String objectSize,
  String? package,

  /// The current progress of the installation.
  required Progress progress,

  /// The function triggered when the user has requested to cancel
  /// the installation.
  required Function() onCancel,

  /// The name of the tool that is being installed so that it can show
  /// appropriate messages for each type.
  required String toolName,
}) {
  return Consumer<DownloadNotifier>(
    builder: (BuildContext context, DownloadNotifier downloadNotifier, _) {
      return (downloadNotifier.downloadProgress != null &&
              downloadNotifier.downloadProgress! < 100)
          ? AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: disabled ? 0.2 : 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 415,
                  height: 120,
                  child: RoundContainer(
                    radius: 0,
                    padding: EdgeInsets.zero,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        LinearProgressIndicator(
                          value: disabled
                              ? 0
                              : (downloadNotifier.downloadProgress ?? 0) / 100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              _color(progress).withOpacity(0.05)),
                          backgroundColor: Colors.transparent,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      '${_getActionName(progress) + (_getActionName(progress) == '' ? '' : ' ')}${toolName.toLowerCase()}.zip',
                                      style: const TextStyle(fontSize: 18)),
                                  VSeparators.xSmall(),
                                  Text(
                                    progress == Progress.FAILED
                                        ? 'Download Failed'
                                        : '${(disabled ? 0 : (downloadNotifier.downloadProgress ?? 0) / 100 * 100).floor()}% • 56 seconds left',
                                    style: TextStyle(
                                      color: context
                                              .read<ThemeChangeNotifier>()
                                              .isDarkTheme
                                          ? AppTheme.darkLightColor
                                          : AppTheme.darkBackgroundColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: LinearProgressIndicator(
                                value: disabled
                                    ? 0
                                    : (downloadNotifier.downloadProgress ?? 0) /
                                        100,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _color(progress)),
                                backgroundColor:
                                    _color(progress).withOpacity(0.1),
                                minHeight: 5,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Row(
                            children: <Widget>[
                              if (progress == Progress.FAILED)
                                _actionButton(
                                  context,
                                  buttonName: 'Retry',
                                  icon: Icon(
                                    Icons.refresh_rounded,
                                    size: 15,
                                    color: context
                                            .read<ThemeChangeNotifier>()
                                            .isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  color: Colors.cyan,
                                  onPressed: () {
                                    // TODO: Handle the retry.
                                  },
                                )
                              else
                                _actionButton(
                                  context,
                                  buttonName: 'Pause',
                                  icon: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      RoundContainer(
                                        child: const SizedBox.shrink(),
                                        padding: EdgeInsets.zero,
                                        height: 12,
                                        color: context
                                                .read<ThemeChangeNotifier>()
                                                .isDarkTheme
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      HSeparators.xSmall(),
                                      RoundContainer(
                                        child: const SizedBox.shrink(),
                                        padding: EdgeInsets.zero,
                                        height: 12,
                                        color: context
                                                .read<ThemeChangeNotifier>()
                                                .isDarkTheme
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ],
                                  ),
                                  color: Colors.blueGrey,
                                  onPressed: () {
                                    // TODO: Handle pausing the download.
                                  },
                                ),
                              _actionButton(
                                context,
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 15,
                                  color: context
                                          .read<ThemeChangeNotifier>()
                                          .isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                color: AppTheme.errorColor,
                                buttonName: 'Cancel',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => DialogTemplate(
                                      child: Column(
                                        children: <Widget>[
                                          const DialogHeader(
                                              title: 'Are you sure?'),
                                          VSeparators.normal(),
                                          informationWidget(
                                              'Are you sure you want to stop downloading $toolName? You will still be able to download it again later.'),
                                          VSeparators.normal(),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: RectangleButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    onCancel();
                                                  },
                                                  hoverColor:
                                                      AppTheme.errorColor,
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              HSeparators.normal(),
                                              Expanded(
                                                child: RectangleButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Back',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink();
    },
  );
}

Color _color(Progress progress) {
  if (progress == Progress.DONE) {
    return kGreenColor;
  } else if (progress == Progress.FAILED) {
    return AppTheme.errorColor;
  } else {
    return AppTheme.primaryColor;
  }
}

String _getActionName(Progress progress) {
  if (progress == Progress.DONE) {
    return 'Downloaded';
  } else if (progress == Progress.EXTRACTING) {
    return 'Extracting';
  } else if (progress == Progress.DOWNLOADING || progress == Progress.STARTED) {
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
