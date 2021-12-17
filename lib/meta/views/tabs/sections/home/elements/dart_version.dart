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

class HomeDartVersionTile extends StatefulWidget {
  const HomeDartVersionTile({Key? key}) : super(key: key);

  @override
  _HomeFlutterVersionStateTile createState() => _HomeFlutterVersionStateTile();
}

class _HomeFlutterVersionStateTile extends State<HomeDartVersionTile> {
  @override
  Widget build(BuildContext context) {
    return RoundContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SvgPicture.asset(Assets.dart, height: 20),
              HSeparators.small(),
              const Expanded(
                child: Text(
                  'Dart 2.14.4',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              HSeparators.xSmall(),
              SvgPicture.asset(Assets.done, height: 20),
            ],
          ),
          VSeparators.normal(),
          const HoverMessageWithIconAction(
            message: 'Dart is already up to date on channel stable',
            icon: Icon(Icons.check_rounded, color: kGreenColor, size: 15),
          ),
          VSeparators.normal(),
          HoverMessageWithIconAction(
            message: 'Checked for new updates 2 days ago',
            icon:
                const Icon(Icons.refresh_rounded, color: kGreenColor, size: 15),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                snackBarTile(context, 'Checking for new Dart updates...',
                    revert: true),
              );
            },
          ),
          VSeparators.normal(),
          const HoverMessageWithIconAction(
            message: 'Last updated 2 weeks ago',
            icon: Icon(Icons.check_rounded, color: kGreenColor, size: 15),
          ),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  child: const Text('Check Updates'),
                  onPressed: () {},
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: RectangleButton(
                  child: const Text('Create New'),
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