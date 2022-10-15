// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';

SnackBar snackBarTile(
  BuildContext context,
  String message, {
  SnackBarType? type,
  Duration? duration,
  SnackBarAction? action,
}) {
  return SnackBar(
    action: action,
    duration: duration ?? const Duration(seconds: 5),
    behavior: SnackBarBehavior.floating,
    width: 600,
    elevation: 0,
    backgroundColor: type == null
        ? Colors.white
        : type == SnackBarType.error
            ? kRedColor
            : type == SnackBarType.warning
                ? kYellowColor
                : kGreenColor,
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
                color: AppTheme.darkBackgroundColor,
              ),
            ),
          ),
        Flexible(
          child: Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyText1,
          ),
        ),
      ],
    ),
  );
}

SnackBarAction? snackBarAction({
  required String text,
  required Function() onPressed,
}) {
  return SnackBarAction(
    label: text,
    onPressed: onPressed,
    textColor: Colors.black,
  );
}

enum SnackBarType { done, warning, error }
