// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/buttons/square_button.dart';
import 'package:manager/meta/utils/app_theme.dart';

Widget titleSection(String title, BuildContext context,
    [List<Widget>? actions]) {
  ThemeData customTheme = Theme.of(context);
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Text(
        title,
        style: TextStyle(
          fontSize: 25,
          color: customTheme.textTheme.bodyText1!.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      const Spacer(),
      Row(children: actions ?? <Widget>[]),
    ],
  );
}

Widget installationStatus(
    InstallationStatus status, String title, String description,
    {String? tooltip,
    VoidCallback? onDownload,
    required BuildContext context}) {
  ThemeData customTheme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.only(left: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            SvgPicture.asset(status == InstallationStatus.done
                ? Assets.done
                : status == InstallationStatus.warning
                    ? Assets.warn
                    : Assets.error),
            HSeparators.normal(),
            Text(
              title,
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            status != InstallationStatus.done
                ? SquareButton(
                    size: 35,
                    color: AppTheme.darkBackgroundColor,
                    icon: Icon(Icons.download,
                        color: customTheme.textTheme.bodyText1!.color,
                        size: 20),
                    tooltip: 'Download ${tooltip!}',
                    onPressed: onDownload!)
                : const SizedBox.shrink(),
          ],
        ),
        status == InstallationStatus.error ||
                status == InstallationStatus.warning
            ? Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: status == InstallationStatus.error
                              ? kRedColor
                              : kYellowColor),
                      height: 40,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: SelectableText(description)),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ],
    ),
  );
}

enum InstallationStatus { done, warning, error }
