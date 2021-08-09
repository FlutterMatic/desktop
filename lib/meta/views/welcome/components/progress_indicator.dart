import 'package:flutter/material.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:provider/provider.dart';

Widget installProgressIndicator({
  /// Whether or not to disable this component.
  required bool disabled,

  /// A string telling the user how much space it will take on the disk.
  required String objectSize,
  String? package,
}) {
  return Consumer<DownloadNotifier>(
      builder: (BuildContext context, DownloadNotifier downloadNotifier, _) {
    return downloadNotifier.progress != null && downloadNotifier.progress! < 100
        ? AnimatedOpacity(
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
                                  '''${downloadNotifier.progress!.floor()}%''',
                                  style: const TextStyle(fontSize: 25),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    // Shows the percentage left based on total size and completed size.
                                    disabled
                                        ? 'Pending Install'
                                        : 'Installing...',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Text(
                                        '~ size on system: ',
                                        style: TextStyle(
                                            color: Color(0xffC1C1C1),
                                            fontSize: 14),
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
                        child: LinearProgressIndicator(
                          value: disabled
                              ? 0
                              : (downloadNotifier.progress ?? 0) / 100,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.lightBlueAccent,
                          ),
                          backgroundColor:
                              Colors.lightBlueAccent.withOpacity(0.2),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )

        /// TODO(@ZiyadF296): Show thi extracting animation.
        // : Lottie.asset(Assets.extracting, frameRate: FrameRate(60));
        : const SizedBox.shrink();
  });
}
