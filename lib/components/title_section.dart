import 'package:flutter/material.dart';
import 'package:flutter_installer/components/square_button.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget titleSection(
    String title, Widget icon, Function() onPressed, String tooltip) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Text(
        title,
        style: const TextStyle(
            fontSize: 25, color: kDarkColor, fontWeight: FontWeight.w500),
      ),
      const Spacer(),
      SquareButton(icon: icon, tooltip: tooltip, onPressed: onPressed),
    ],
  );
}

Widget installationStatus(InstallationStatus status, String title,
    String description, Function() onDownload) {
  return Padding(
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
                    size: 30,
                    icon: const Icon(Iconsdata.download),
                    tooltip: 'Download $title',
                    onPressed: onDownload)
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
                      height: 60,
                      color: status == InstallationStatus.error
                          ? kRedColor
                          : kYellowColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SelectableText(description),
                    ),
                  ],
                ))
            : const SizedBox.shrink(),
      ],
    ),
  );
}

enum InstallationStatus { done, warning, error }
