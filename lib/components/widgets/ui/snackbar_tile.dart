import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/constants.dart';

SnackBar snackBarTile(String message, {SnackBarType? type}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    width: 600,
    elevation: 0,
    backgroundColor: const Color(0xFF373E47),
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
        Flexible(child: Text(message)),
      ],
    ),
  );
}

enum SnackBarType { done, warning, error }
