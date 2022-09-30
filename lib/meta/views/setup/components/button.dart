// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';

const List<Progress> _disabledProgresses = <Progress>[
  Progress.extracting,
  Progress.downloading,
  Progress.checking,
  Progress.started,
];

class SetUpButton extends StatelessWidget {
  final Progress progress;
  final VoidCallback? onContinue;
  final VoidCallback? onInstall;
  final String? buttonText;
  final bool loading;

  const SetUpButton({
    required this.progress,
    required this.onInstall,
    required this.onContinue,
    this.loading = false,
    this.buttonText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        bool disabled = _disabledProgresses.contains(progress);
        ThemeState themeState = ref.watch(themeStateController);

        return SizedBox(
          width: 210,
          height: 50,
          child: IgnorePointer(
            ignoring: (disabled || loading),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: (disabled || loading) ? 0.2 : 1,
              child: RectangleButton(
                onPressed: progress == Progress.done ? onContinue : onInstall,
                color: themeState.darkTheme
                    ? AppTheme.lightBackgroundColor
                    : AppTheme.darkBackgroundColor,
                hoverColor: themeState.darkTheme
                    ? AppTheme.lightCardColor
                    : AppTheme.darkCardColor,
                child: loading
                    ? const Spinner(size: 20, thickness: 2)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            buttonText ??
                                (progress == Progress.done
                                    ? 'Continue'
                                    : 'Check'),
                            style: TextStyle(
                              color: themeState.darkTheme
                                  ? AppTheme
                                      .lightTheme.textTheme.bodyText1!.color
                                  : AppTheme
                                      .darkTheme.textTheme.bodyText1!.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: themeState.darkTheme
                                ? AppTheme.lightTheme.iconTheme.color
                                : AppTheme.darkTheme.iconTheme.color,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
