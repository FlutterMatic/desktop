// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/dart_version.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/flutter_version.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/java_version.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/setup_guide.dart';

class HomeMainSection extends StatefulWidget {
  const HomeMainSection({Key? key}) : super(key: key);

  @override
  State<HomeMainSection> createState() => _HomeMainSectionState();
}

class _HomeMainSectionState extends State<HomeMainSection> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            const HomeSetupGuideTile(),
            VSeparators.normal(),
            // TODO: Use isolates for each individual tile. It's impacting performance.
            Row(
              children: <Widget>[
                const Expanded(child: HomeFlutterVersionTile()),
                HSeparators.normal(),
                const Expanded(child: HomeDartVersionTile()),
              ],
            ),
            VSeparators.normal(),
            Row(
              children: <Widget>[
                const Expanded(child: HomeJavaVersionTile()),
                HSeparators.normal(),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
