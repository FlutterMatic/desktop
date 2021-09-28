import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/app_theme.dart';

class WelcomeButton extends StatelessWidget {
  final Progress progress;
  final VoidCallback? onContinue;
  final VoidCallback? onInstall;
  final String? buttonText;
  final bool loading;

  const WelcomeButton({
    required this.progress,
    required this.onInstall,
    required this.onContinue,
    this.loading = false,
    this.buttonText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _disabled = progress == Progress.extracting ||
        progress == Progress.downloading ||
        progress == Progress.checking ||
        progress == Progress.started;
    return SizedBox(
      width: 210,
      height: 50,
      child: IgnorePointer(
        ignoring: (_disabled || loading),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: (_disabled || loading) ? 0.2 : 1,
          child: RectangleButton(
            onPressed: progress == Progress.done ? onContinue : onInstall,
            color: AppTheme.darkBackgroundColor,
            hoverColor: AppTheme.darkCardColor,
            child: loading
                ? const Spinner(size: 20, color: Colors.white, thickness: 2)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        buttonText ??
                            (progress == Progress.done ? 'Continue' : 'Check'),
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
