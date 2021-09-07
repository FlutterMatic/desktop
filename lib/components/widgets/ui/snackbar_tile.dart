import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';

SnackBar snackBarTile(BuildContext context, String message,
    {SnackBarType? type, Duration? duration}) {
  return SnackBar(
    duration: duration ?? const Duration(seconds: 5),
    behavior: SnackBarBehavior.floating,
    width: 600,
    elevation: 0,
    backgroundColor: context.read<ThemeChangeNotifier>().isDarkTheme
        ? AppTheme.darkCardColor
        : AppTheme.lightTheme.primaryColorLight,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    content: Row(
      children: <Widget>[
        if (type != null)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              height: 25,
              width: 25,
              child: SvgPicture.asset(type == SnackBarType.done
                  ? Assets.done
                  : type == SnackBarType.warning
                      ? Assets.warn
                      : Assets.error),
            ),
          ),
        Flexible(
          child: Text(
            message,
            style: context.read<ThemeChangeNotifier>().isDarkTheme
                ? AppTheme.darkTheme.textTheme.bodyText1
                : AppTheme.lightTheme.textTheme.bodyText1,
          ),
        ),
      ],
    ),
  );
}

enum SnackBarType { done, warning, error }
