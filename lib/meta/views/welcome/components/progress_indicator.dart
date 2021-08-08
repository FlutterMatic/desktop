import 'package:flutter/material.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:provider/provider.dart';

Widget installProgressIndicator({
  /// Whether or not to disable this component.
  required bool disabled,

  /// The total that has been download so far from object.
  // required double totalInstalled,
  // required int progress,

  /// The total size of the object that is going to be downloaded.
  // required double totalSize,

  /// A string telling the user how much space it will take on the disk.
  required String objectSize,
}) {
  // if (totalInstalled > totalSize) {
  //   throw Exception(
  //       'Total downloaded size cannot be larger than the total object size.');
  // }

  return Consumer<DownloadNotifier>(
      builder: (BuildContext context, DownloadNotifier downloadNotifier, _) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: disabled ? 0 : 1,
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
                    color: const Color(0xffE0E7EC),
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
                    color: const Color(0xff40CAFF),
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
