import 'package:flutter/material.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/core/notifiers/theme.notifier.dart';

Widget infoWidget(BuildContext context, String text) {
  return RoundContainer(
    color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.blueGrey.withOpacity(0.2) : AppTheme.lightCardColor,
    radius: 5,
    child: Row(
      children: <Widget>[
        const Icon(Icons.info),
        const SizedBox(width: 8),
        Expanded(child: SelectableText(text)),
      ],
    ),
  );
}
