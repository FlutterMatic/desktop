// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/ui/linear_progress_indicator.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class LoadActivityMessageElement extends StatelessWidget {
  final String message;

  const LoadActivityMessageElement({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundContainer(
      child: Builder(
        builder: (_) {
          if (message.isEmpty) {
            return const CustomLinearProgressIndicator(includeBox: false);
          } else {
            return Row(
              children: <Widget>[
                Expanded(
                  child: Text(message,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                HSeparators.small(),
                const SizedBox(
                  width: 50,
                  child: CustomLinearProgressIndicator(includeBox: false),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
