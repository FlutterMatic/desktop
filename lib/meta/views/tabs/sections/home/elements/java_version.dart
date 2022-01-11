// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/meta/views/tabs/sections/home/elements/hover_info_tile.dart';

class HomeJavaVersionTile extends StatefulWidget {
  const HomeJavaVersionTile({Key? key}) : super(key: key);

  @override
  _HomeFlutterVersionStateTile createState() => _HomeFlutterVersionStateTile();
}

class _HomeFlutterVersionStateTile extends State<HomeJavaVersionTile> {
  @override
  Widget build(BuildContext context) {
    return RoundContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SvgPicture.asset(Assets.java, height: 20),
              HSeparators.small(),
              const Expanded(
                child: Text(
                  'Java',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              HSeparators.xSmall(),
              SvgPicture.asset(Assets.error, height: 20),
            ],
          ),
          VSeparators.normal(),
          const HoverMessageWithIconAction(
            message: 'Java is not installed on your device',
            icon: Icon(Icons.check_rounded, color: kGreenColor, size: 15),
          ),
          VSeparators.normal(),
          HoverMessageWithIconAction(
            message: 'Install Java',
            icon: const Icon(Icons.download_rounded,
                color: kGreenColor, size: 15),
            onPressed: () {
              // TODO(@yahu1031): Install Java
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                snackBarTile(
                  context,
                  'Installing Java...',
                ),
              );
            },
          ),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  child: const Text('Install Java'),
                  onPressed: () {},
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
