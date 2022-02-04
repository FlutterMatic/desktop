// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';

class BgLoadingIndicator extends StatelessWidget {
  final String msg;
  const BgLoadingIndicator(this.msg, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: msg,
      child: RoundContainer(
        width: 40,
        height: 40,
        radius: 60,
        borderWith: 2,
        disableInnerRadius: true,
        borderColor: Colors.blueGrey.withOpacity(0.5),
        child: const Spinner(thickness: 2),
      ),
    );
  }
}
