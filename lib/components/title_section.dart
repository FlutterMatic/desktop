import 'package:flutter/material.dart';
import 'package:flutter_installer/components/square_button.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget titleSection(String title, Widget icon, Function() onPressed,
    {required BuildContext context}) {
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
      SquareButton(
        color: customTheme.primaryColorLight,
        icon: icon,
        onPressed: onPressed,
      ),
    ],
  );
}

Widget installationStatus(
        InstallationStatus status, String title, String description,
        {String? tooltip, Function()? onDownload, required Color hoverColor}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SvgPicture.asset(status == InstallationStatus.done
                  ? Assets.done
                  : status == InstallationStatus.warning
                      ? Assets.warning
                      : Assets.error),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(fontSize: 20),
              ),
              const Spacer(),
              status != InstallationStatus.done
                  ? SquareButton(
                      size: 35,
                      icon: const Icon(Iconsdata.download, size: 20),
                      tooltip: 'Download ${tooltip!}',
                      onPressed: onDownload!,
                    )
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
                      Expanded(
                        child: SelectableText(description),
                      ),
                    ],
                  ))
              : const SizedBox.shrink(),
        ],
      ),
    );

enum InstallationStatus { done, warning, error }
