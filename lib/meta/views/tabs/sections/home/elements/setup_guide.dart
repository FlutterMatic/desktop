// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/project/select.dart';
import 'package:fluttermatic/components/dialog_templates/settings/settings.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';
import 'package:fluttermatic/meta/views/tabs/components/circle_chart.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';

class HomeSetupGuideTile extends StatefulWidget {
  const HomeSetupGuideTile({Key? key}) : super(key: key);

  @override
  _HomeSetupGuideTileState createState() => _HomeSetupGuideTileState();
}

class _HomeSetupGuideTileState extends State<HomeSetupGuideTile> {
  bool _showGuide = false;
  bool _isHovering = false;

  double _percent = 0;

  final List<int> _doneHashes = <int>[];

  Future<void> _loadGuide() async {
    if (!SharedPref().pref.containsKey(SPConst.homeShowGuide)) {
      await SharedPref().pref.setBool(SPConst.homeShowGuide, true);
      if (mounted) {
        setState(() => _showGuide = true);
      }
    } else if (mounted) {
      setState(() => _showGuide =
          SharedPref().pref.getBool(SPConst.homeShowGuide) ?? true);
    }

    if (SharedPref().pref.containsKey(SPConst.guideFinishedHashes)) {
      _doneHashes.clear();
      _doneHashes.addAll(SharedPref()
          .pref
          .getStringList(SPConst.guideFinishedHashes)!
          .map(int.parse)
          .toList());

      _percent = _doneHashes.length / _guides.length;
    }
  }

  String _getPercentage() {
    if (_percent == 1) {
      return '100';
    }

    if (_percent.toString().contains('.')) {
      if (_percent.toString().allMatches('0').length ==
          _percent.toString().length - 1) {
        return '0';
      }
    }

    String _value =
        _percent.toString().substring(_percent.toString().indexOf('.') + 1);

    if (_value.length == 1 && _value != '0') {
      return _value + '0';
    } else {
      if (_value.length > 2) {
        return _value.substring(0, 2);
      } else {
        return _value;
      }
    }
  }

  @override
  void initState() {
    _loadGuide();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_showGuide) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: MouseRegion(
          onHover: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Stack(
            children: <Widget>[
              RoundContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircularPercentIndicator(
                          backgroundColor: (AppTheme.darkTheme.buttonTheme
                                      .colorScheme?.primary ??
                                  kGreenColor)
                              .withOpacity(0.2),
                          size: 50,
                          percent: _percent,
                          center: Text(
                            '${_getPercentage()}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        HSeparators.large(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Complete setting up FlutterMatic',
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                              VSeparators.xSmall(),
                              const Text(
                                'Customize your preferences. This helps make using FlutterMatic easier and make the most out of it.',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    VSeparators.xLarge(),
                    VSeparators.small(),
                    ..._guides.map((_GuideModel e) {
                      return _GuideItem(
                        text: e.text,
                        context: context,
                        isDone: _doneHashes.contains(e.text.hashCode),
                        onPressed: (_) async {
                          if (mounted) {
                            if (_doneHashes.contains(e.text.hashCode)) {
                              return;
                            } else {
                              _doneHashes.add(e.text.hashCode);
                            }

                            double _totalAdd = 1 / _guides.length;

                            if (_percent + _totalAdd <= 1) {
                              setState(() => _percent += _totalAdd);
                            }

                            e.onPressed(context);

                            await SharedPref().pref.setStringList(
                                SPConst.guideFinishedHashes,
                                _doneHashes
                                    .map((int e) => e.toString())
                                    .toList());
                          }
                        },
                      );
                    }).toList(),
                    infoWidget(context,
                        'As we are preparing for more upcoming features, we will be adding more guides here.'),
                  ],
                ),
              ),
              if (_isHovering)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: SquareButton(
                          size: 25,
                          color: Colors.transparent,
                          tooltip: 'Clear all',
                          icon: Icon(
                            Icons.clear_all,
                            size: 15,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                          onPressed: () async {
                            if (_doneHashes.isEmpty) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(context,
                                    'Begin setting up FlutterMatic by clicking on some of the items below.',
                                    type: SnackBarType.warning),
                              );

                              return;
                            }

                            await SharedPref()
                                .pref
                                .remove(SPConst.guideFinishedHashes);
                            setState(() {
                              _doneHashes.clear();
                              _percent = 0;
                            });
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              snackBarTile(
                                context,
                                'Guide has been reset. Let\'s start over!',
                                type: SnackBarType.done,
                              ),
                            );
                          },
                        ),
                      ),
                      SquareButton(
                        size: 25,
                        color: Colors.transparent,
                        tooltip: 'Dismiss Guide',
                        icon: Icon(Icons.close_rounded,
                            color: Colors.grey.withOpacity(0.6), size: 15),
                        onPressed: () async {
                          setState(() => _showGuide = false);
                          await SharedPref()
                              .pref
                              .setBool(SPConst.homeShowGuide, false);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            snackBarTile(
                              context,
                              'Dismissed guide successfully. You can bring it back in settings.',
                              type: SnackBarType.done,
                              action: snackBarAction(
                                text: 'Undo',
                                onPressed: () async {
                                  setState(() => _showGuide = true);
                                  await SharedPref()
                                      .pref
                                      .setBool(SPConst.homeShowGuide, true);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _GuideItem extends StatefulWidget {
  final String text;
  final bool isDone;
  final BuildContext context;
  final Function(BuildContext context) onPressed;

  const _GuideItem({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.context,
    required this.isDone,
  }) : super(key: key);

  @override
  __GuideItemState createState() => __GuideItemState();
}

class __GuideItemState extends State<_GuideItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: MouseRegion(
        onHover: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: MaterialButton(
          onPressed: () => widget.onPressed(widget.context),
          hoverColor: Colors.transparent,
          child: Row(
            children: <Widget>[
              Container(
                height: 20,
                width: 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppTheme.primaryColor
                      .withOpacity(widget.isDone ? 1 : 0.4),
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: _isHovering ? AppTheme.primaryColor : null,
                    decoration: widget.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
              HSeparators.normal(),
              if (_isHovering)
                const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideModel {
  final String text;
  final Function(BuildContext context) onPressed;

  const _GuideModel({
    required this.text,
    required this.onPressed,
  });
}

final List<_GuideModel> _guides = <_GuideModel>[
  _GuideModel(
    text:
        'Set your projects path where we can find all of your Flutter projects. You can then manage these projects easily from the projects tab.',
    onPressed: (BuildContext context) {
      showDialog(
        context: context,
        builder: (_) => const SettingDialog(
          goToPage: SettingsPage.projects,
        ),
      );
    },
  ),
  _GuideModel(
    text: 'Create your first Flutter or Dart package using FlutterMatic.',
    onPressed: (_) =>
        showDialog(context: _, builder: (_) => const SelectProjectTypeDialog()),
  ),
  _GuideModel(
    text:
        'Automate your Flutter workspace by setting up workflows. This helps you setup commands to run for projects when you press run.',
    onPressed: (_) =>
        showDialog(context: _, builder: (_) => const StartUpWorkflow()),
  ),
  // _GuideModel(
  //   text:
  //       'Scan your project\'s dependencies to make sure that they are all up-to-date.',
  //   onPressed: (_) {},
  // ),
  // _GuideModel(
  //   text:
  //       'Add your own pubspec.yaml structure for new projects or packages created to include a default set of dependencies.',
  //   onPressed: (_) {},
  // ),
];
