import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/app_theme.dart';

class WelcomeButton extends StatelessWidget {
  final String toolName;
  final Progress progress;
  final VoidCallback? onContinue;
  final VoidCallback? onInstall;
  final String? buttonText;

  const WelcomeButton({
    required this.toolName,
    required this.progress,
    required this.onInstall,
    required this.onContinue,
    this.buttonText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _disabled = progress == Progress.EXTRACTING ||
        progress == Progress.DOWNLOADING ||
        progress == Progress.CHECKING ||
        progress == Progress.STARTED;
    return SizedBox(
      width: 210,
      height: 50,
      child: IgnorePointer(
        ignoring: _disabled,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _disabled ? 0 : 1,
          child: RectangleButton(
            onPressed: _disabled
                ? null
                : progress == Progress.DONE
                    ? onContinue
                    : onInstall,
            color: AppTheme.lightTheme.buttonColor,
            hoverColor: AppTheme.lightTheme.accentColor,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  buttonText ??
                      (progress == Progress.DONE ? 'Continue' : 'Check'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded,
                    size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
