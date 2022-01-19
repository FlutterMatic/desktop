// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/shared_pref.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/components/widgets/ui/shimmer.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/models/check_response.model.dart';
import 'package:manager/core/services/checks/check.services.dart';
import 'package:manager/meta/utils/shared_pref.dart';
import 'package:manager/meta/utils/time_ago.dart';
import 'package:manager/meta/views/tabs/sections/home/elements/hover_info_tile.dart';

class HomeDartVersionTile extends StatefulWidget {
  const HomeDartVersionTile({Key? key}) : super(key: key);

  @override
  _HomeFlutterVersionStateTile createState() => _HomeFlutterVersionStateTile();
}

class _HomeFlutterVersionStateTile extends State<HomeDartVersionTile> {
  Version? _version;
  String _channel = '...';

  bool get _doneLoading => _version != null && _channel != '...';

  Future<void> _load() async {
    ServiceCheckResponse _result = await CheckServices.checkDart();

    if (mounted) {
      setState(() {
        _version = _result.version;
        _channel = _result.channel ?? '...';
      });
    }
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RoundContainer(
      child: Shimmer.fromColors(
        enabled: !_doneLoading,
        child: IgnorePointer(
          ignoring: !_doneLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SvgPicture.asset(Assets.dart, height: 20),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      'Dart - ${_version ?? '...'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  HSeparators.xSmall(),
                  SvgPicture.asset(Assets.done, height: 20),
                ],
              ),
              VSeparators.normal(),
              HoverMessageWithIconAction(
                message: 'Dart is up to date on channel $_channel',
                icon: const Icon(Icons.check_rounded,
                    color: kGreenColor, size: 15),
              ),
              VSeparators.normal(),
              HoverMessageWithIconAction(
                message: SharedPref()
                        .pref
                        .containsKey(SPConst.lastDartUpdateCheck)
                    ? 'Checked for new updates ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastDartUpdateCheck) ?? DateTime.now().toString()))}'
                    : 'Never checked for new updates before',
                icon: const Icon(Icons.refresh_rounded,
                    color: kGreenColor, size: 15),
                onPressed: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    snackBarTile(
                      context,
                      'Checking for new Dart updates...',
                    ),
                  );
                },
              ),
              VSeparators.normal(),
              HoverMessageWithIconAction(
                message: SharedPref().pref.containsKey(SPConst.lastDartUpdate)
                    ? 'Last updated ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastDartUpdate) ?? DateTime.now().toString()))}'
                    : 'Never updated before',
                icon: const Icon(Icons.check_rounded,
                    color: kGreenColor, size: 15),
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
        ),
      ),
    );
  }
}
