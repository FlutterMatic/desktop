import 'package:flutter/material.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';

class CustomProgressIndicator extends StatelessWidget {
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
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
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
          return hLoadingIndicator(context: context);
        }
      },
    );
  }
}
