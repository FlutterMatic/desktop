// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/meta/utils/app_theme.dart';

SnackBar snackBarTile(BuildContext context, String message,
    {SnackBarType? type, Duration? duration, bool revert = false}) {
  return SnackBar(
    duration: duration ?? const Duration(seconds: 5),
    behavior: SnackBarBehavior.floating,
    width: 600,
    elevation: 0,
    backgroundColor: (revert && type != null)
        ? (type == SnackBarType.error
            ? kRedColor
            : type == SnackBarType.warning
                ? kYellowColor
                : kGreenColor)
        : (Theme.of(context).isDarkTheme ? AppTheme.darkCardColor : AppTheme.lightTheme.primaryColorLight),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    content: Row(
      children: <Widget>[
        if (type != null)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              height: 25,
              width: 25,
              child: SvgPicture.asset(
                type == SnackBarType.done
                    ? Assets.done
                    : type == SnackBarType.warning
                        ? Assets.warn
                        : Assets.error,
                color: revert
                    ? (Theme.of(context).isDarkTheme ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor)
                    : (type == SnackBarType.done
                        ? kGreenColor
                        : type == SnackBarType.warning
                            ? kYellowColor
                            : kRedColor),
              ),
            ),
          ),
        Flexible(
          child: Text(
            message,
            style: Theme.of(context).isDarkTheme && !revert
                ? AppTheme.darkTheme.textTheme.bodyText1
                : AppTheme.lightTheme.textTheme.bodyText1,
          ),
        ),
      ],
    ),
  );
}

enum SnackBarType { done, warning, error }
