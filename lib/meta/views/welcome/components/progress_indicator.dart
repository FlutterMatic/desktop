import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';

Widget installProgressIndicator({
  /// Whether or not to disable this component.
  required bool disabled,

  /// A string telling the user how much space it will take on the disk.
  required String objectSize,
}) {
  return Consumer<DownloadNotifier>(
      builder: (BuildContext context, DownloadNotifier downloadNotifier, _) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: disabled ? 0.2 : 1,
      child: SizedBox(
        width: 330,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      const Text('~ size on system: ',
                          style: TextStyle(
                              color: Color(0xffC1C1C1), fontSize: 14)),
                      Text(objectSize, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  // Shows the percentage left based on total size and completed size.
                  disabled
                      ? 'Start installing'
                      : '${downloadNotifier.progress ?? 0}%',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Stack(
              children: <Widget>[
                Container(
                  height: 3,
                  width: 330,
                  decoration: BoxDecoration(
                    color: context.read<ThemeChangeNotifier>().isDarkTheme
                        ? AppTheme.darkLightColor
                        : Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: 3,
                  // Gets the percentage of the object that has been downloaded.
                  // then sets the width depending on the percentage.

                  width: disabled ? 0 : (downloadNotifier.progress ?? 0) * 3.3,
                  decoration: BoxDecoration(
                    color: context.read<ThemeChangeNotifier>().isDarkTheme
                        ? kGreenColor
                        : Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  });
}
