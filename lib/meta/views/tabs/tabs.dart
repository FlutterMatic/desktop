// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/settings/settings.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/views/tabs/sections/home/home.dart';
import 'package:manager/meta/views/tabs/sections/projects/projects.dart';
import 'package:manager/meta/views/tabs/sections/pub/pub.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeTabObject _selectedTab;

  final List<HomeTabObject> _tabs = const <HomeTabObject>[
    HomeTabObject(
      'Home',
      Assets.home,
      HomeMainSection(),
    ),
    HomeTabObject(
      'Projects',
      Assets.project,
      HomeProjectsSection(),
    ),
    HomeTabObject(
      'Pub Packages',
      Assets.package,
      HomePubSection(),
    ),
  ];

  @override
  void initState() {
    setState(() => _selectedTab = _tabs.first);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    Size _size = MediaQuery.of(context).size;

    bool _showShortView = _size.width < 900;
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: _showShortView ? 50 : 230,
                  child: ColoredBox(
                    color: Colors.blueGrey.withOpacity(0.08),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _showShortView ? 5 : 15,
                        vertical: _showShortView ? 5 : 20,
                      ),
                      child: Column(
                        children: <Widget>[
                          ..._tabs.map(
                            (HomeTabObject e) {
                              return _tabTile(
                                context,
                                icon: SvgPicture.asset(
                                  e.icon,
                                  color: context
                                          .read<ThemeChangeNotifier>()
                                          .isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                name: e.name,
                                onPressed: () =>
                                    setState(() => _selectedTab = e),
                                selected: _selectedTab == e,
                              );
                            },
                          ),
                          const Spacer(),
                          // Short view
                          if (_size.width < 900)
                            Column(
                              children: <Widget>[
                                if (isNewVersionAvailable)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child:
                                        _updateAppButton(context, customTheme),
                                  ),
                                _tabTile(
                                  context,
                                  icon: SvgPicture.asset(
                                    Assets.settings,
                                    color: context
                                            .read<ThemeChangeNotifier>()
                                            .isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  name: 'Settings',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => const SettingDialog(),
                                    );
                                  },
                                  selected: true,
                                ),
                              ],
                            )
                          else
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _tabTile(
                                    context,
                                    icon: SvgPicture.asset(
                                      Assets.settings,
                                      color: context
                                              .read<ThemeChangeNotifier>()
                                              .isDarkTheme
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    name: 'Settings',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => const SettingDialog(),
                                      );
                                    },
                                    selected: true,
                                  ),
                                ),
                                if (isNewVersionAvailable)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 10),
                                    child:
                                        _updateAppButton(context, customTheme),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: _selectedTab.child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeTabObject {
  final String name;
  final String icon;
  final Widget child;

  const HomeTabObject(this.name, this.icon, this.child);
}

Widget _tabTile(
  BuildContext context, {
  required Widget icon,
  required String name,
  required Function() onPressed,
  required bool selected,
}) {
  ThemeData customTheme = Theme.of(context);
  Size _size = MediaQuery.of(context).size;

  bool _showShortView = _size.width < 900;
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: RectangleButton(
      width: 200,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      color: selected
          ? customTheme.colorScheme.secondary.withOpacity(0.2)
          : Colors.transparent,
      padding: EdgeInsets.all(_showShortView ? 5 : 10),
      onPressed: onPressed,
      child: Align(
        alignment: Alignment.centerLeft,
        child: !_showShortView
            ? Row(
                children: <Widget>[
                  icon,
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      name,
                      style: TextStyle(
                        color: customTheme.textTheme.bodyText1!.color!
                            .withOpacity(selected ? 1 : .4),
                      ),
                    ),
                  ),
                ],
              )
            : Center(child: icon),
      ),
    ),
  );
}

Widget _updateAppButton(BuildContext context, ThemeData theme) {
  return RectangleButton(
    width: 40,
    height: 40,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    color: theme.colorScheme.secondary.withOpacity(0.2),
    child: const Icon(Icons.download_rounded),
    onPressed: () {
      // TODO(@ZiyadF296): Show update FlutterMatic dialog
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'There is a new version of FlutterMatic ready to be installed on your device.',
          type: SnackBarType.warning,
          revert: true,
        ),
      );
    },
  );
}
