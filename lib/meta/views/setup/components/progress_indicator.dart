// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/notifiers/models/state/general/download.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/views/setup/components/loading_indicator.dart';

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        DownloadState downloadState = ref.watch(downloadStateController);

        if (downloadState.downloadProgress < 100) {
          return SizedBox(
            width: 200,
            child: Column(
              children: <Widget>[
                hLoadingIndicator(
                  value: downloadState.downloadProgress / 100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('${downloadState.downloadProgress.floor()}%'),
                    Text(downloadState.remainingTime ==
                            const DownloadState().remainingTime
                        ? 'Calculating...'
                        : '${downloadState.remainingTime} left'),
                  ],
                ),
              ],
            ),
          );
        } else {
          return hLoadingIndicator(context: context);
        }
      },
    );
  }
}
