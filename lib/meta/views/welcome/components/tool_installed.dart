import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';

Widget welcomeToolInstalled(BuildContext context,
    {required String title, required String message}) {
  return RoundContainer(
    color: context.read<ThemeChangeNotifier>().isDarkTheme
        ? Colors.blueGrey.withOpacity(0.2)
        : AppTheme.lightCardColor,
    padding: const EdgeInsets.all(15),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.check_rounded, color: Color(0xff40CAFF)),
        HSeparators.normal(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
              VSeparators.xSmall(),
              Text(
                message,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
