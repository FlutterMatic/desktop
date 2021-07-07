import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:manager/core/notifiers/theme.notifier.dart';
import 'package:provider/provider.dart';

class ThemeToggle extends StatefulWidget {
  const ThemeToggle({Key? key}) : super(key: key);

  @override
  _ThemeToggleState createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool reverse = false;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeChangeNotifier _themeChange =
        Provider.of<ThemeChangeNotifier>(context);
    return GestureDetector(
      onTap: () async {
        setState(() {
          reverse = !reverse;
        });
        if (reverse) {
          _controller
            ..duration = _controller.duration
            ..reverse();
          await _themeChange.updateTheme(!reverse);
        } else {
          _controller
            ..duration = _controller.duration
            ..forward();
          await _themeChange.updateTheme(!reverse);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Lottie.asset(
          'assets/lottie/theme.json',
          width: 100,
          frameRate: FrameRate.max,
          controller: _controller,
          onLoaded: (LottieComposition composition) {
            _controller
              ..duration = composition.duration
              ..reverse();
          },
          repeat: false,
          reverse: true,
        ),
      ),
    );
  }
}
