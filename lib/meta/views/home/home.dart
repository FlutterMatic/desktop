import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/settings/settings.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/views/home/sections/home.dart';
import 'package:manager/meta/views/home/sections/projects.dart';
import 'package:manager/meta/views/home/sections/pub.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeTabObject _selectedTab;

  final List<HomeTabObject> _tabs = const <HomeTabObject>[
    HomeTabObject('Home', HomeSection()),
    HomeTabObject('Projects', HomeProjectSection()),
    HomeTabObject('Pub Packages', HomePubSection()),
  ];

  @override
  void initState() {
    setState(() => _selectedTab = _tabs.first);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 230,
                child: ColoredBox(
                  color: Colors.blueGrey.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: <Widget>[
                        ..._tabs.map(
                          (HomeTabObject e) => _tabTile(
                            e.name,
                            () => setState(() => _selectedTab = e),
                            _selectedTab == e,
                            context,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: <Widget>[
                            IconButton(
                              splashRadius: 1,
                              icon: SvgPicture.asset(
                                Assets.settings,
                                color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const SettingDialog(),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: _selectedTab.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTabObject {
  final String name;
  final Widget child;

  const HomeTabObject(this.name, this.child);
}

Widget _tabTile(String name, Function() onPressed, bool selected, BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: RectangleButton(
      width: 200,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      color: selected ? customTheme.accentColor.withOpacity(0.2) : Colors.transparent,
      padding: const EdgeInsets.all(10),
      onPressed: onPressed,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          name,
          style: TextStyle(color: customTheme.textTheme.bodyText1!.color!.withOpacity(selected ? 1 : .4)),
        ),
      ),
    ),
  );
}
