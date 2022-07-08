// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:fluttermatic/app/constants.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class ComingSoonTile extends StatefulWidget {
  const ComingSoonTile({Key? key}) : super(key: key);

  @override
  State<ComingSoonTile> createState() => _ComingSoonTileState();
}

class _ComingSoonTileState extends State<ComingSoonTile> {
  bool _isVisible = false;

  @override
  void initState() {
    Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 0.8 : 0,
      duration: const Duration(milliseconds: 300),
      child: RoundContainer(
        padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
        color: kGreenColor.withOpacity(0.1),
        radius: 50,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const RoundContainer(
              height: 5,
              width: 5,
              color: kGreenColor,
              child: SizedBox.shrink(),
            ),
            HSeparators.xSmall(),
            const Text('Coming Soon', style: TextStyle(color: kGreenColor)),
          ],
        ),
      ),
    );
  }
}
