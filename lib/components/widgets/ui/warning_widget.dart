import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/meta/utils/app_theme.dart';

Widget informationWidget(String text,
    {InformationType type = InformationType.WARNING, bool showIcon = true}) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: RoundContainer(
      color: _getColor(type).withOpacity(0.1),
      borderColor: _getColor(type),
      radius: 5,
      borderWith: 1.5,
      child: Row(
        children: <Widget>[
          if (showIcon)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: type == InformationType.INFO
                  ? const Icon(Icons.info_rounded)
                  : SvgPicture.asset(
                      type == InformationType.WARNING
                          ? Assets.warn
                          : type == InformationType.ERROR
                              ? Assets.error
                              : Assets.done,
                      height: 20),
            ),
          Expanded(child: Text(text)),
        ],
      ),
    ),
  );
}

Color _getColor(InformationType type) {
  if (type == InformationType.WARNING) {
    return kYellowColor;
  } else if (type == InformationType.ERROR) {
    return kRedColor;
  } else if (type == InformationType.GREEN) {
    return kGreenColor;
  } else {
    return AppTheme.darkLightColor;
  }
}

enum InformationType {
  INFO,
  WARNING,
  ERROR,
  GREEN,
}
