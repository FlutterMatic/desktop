import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 415,
          height: 90,
          child: RoundContainer(
            radius: 0,
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${downloadNotifier.progress ?? 0}%',
                            style: const TextStyle(fontSize: 25),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              // Shows the percentage left based on total size and completed size.
                              disabled ? 'Pending Install' : 'Installing...',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text(
                                  '~ size on system: ',
                                  style: TextStyle(
                                      color: Color(0xffC1C1C1), fontSize: 14),
                                ),
                                Text(
                                  objectSize,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            // const SizedBox(width: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: 5,
                        width: 415,
                        decoration: BoxDecoration(
                          color: context.read<ThemeChangeNotifier>().isDarkTheme
                              ? AppTheme.darkLightColor
                              : Colors.black,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        height: 5,
                        // Gets the percentage of the object that has been downloaded.
                        // then sets the width depending on the percentage.

                        width: disabled
                            ? 0
                            : (downloadNotifier.progress ?? 0) * 4.15,
                        decoration: BoxDecoration(
                          color: context.read<ThemeChangeNotifier>().isDarkTheme
                              ? kGreenColor
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  });
}
