// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/setup_guide.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/version_tiles/dart_version.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/version_tiles/flutter_version.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/version_tiles/git_version.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/version_tiles/java_version.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/version_tiles/studio_version.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/version_tiles/vsc_version.dart';

class HomeMainSection extends ConsumerStatefulWidget {
  const HomeMainSection({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeMainSection> createState() => _HomeMainSectionState();
}

class _HomeMainSectionState extends ConsumerState<HomeMainSection> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .watch(checkServicesStateNotifier.notifier)
          .init((await getApplicationSupportDirectory()).path);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            const HomeSetupGuideTile(),
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
                const Expanded(child: HomeVSCVersionTile()),
                HSeparators.normal(),
                const Expanded(child: HomeStudioVersionTile()),
              ],
            ),
            VSeparators.normal(),
            Row(
              children: <Widget>[
                const Expanded(child: HomeJavaVersionTile()),
                HSeparators.normal(),
                const Expanded(child: HomeGitVersionTile()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
