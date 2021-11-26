// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/shared_pref.dart';
import 'package:manager/components/widgets/buttons/square_button.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:manager/meta/views/tabs/sections/home/elements/circle_chart.dart';

class HomeMainSection extends StatefulWidget {
  const HomeMainSection({Key? key}) : super(key: key);

  @override
  State<HomeMainSection> createState() => _HomeMainSectionState();
}

class _HomeMainSectionState extends State<HomeMainSection> {
  bool _showGuide = false;

  Future<void> _loadGuide() async {
    if (!SharedPref().pref.containsKey(SPConst.homeShowGuide)) {
      await SharedPref().pref.setBool(SPConst.homeShowGuide, true);
      setState(() => _showGuide = true);
    } else {
      setState(() => _showGuide =
          SharedPref().pref.getBool(SPConst.homeShowGuide) ?? true);
    }
  }

  @override
  void initState() {
    _loadGuide();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          if (_showGuide)
            Padding(
              padding: const EdgeInsets.all(15),
              child: Stack(
                children: <Widget>[
                  RoundContainer(
                    child: Row(
                      children: <Widget>[
                        CircularPercentIndicator(
                          backgroundColor: (AppTheme.darkTheme.buttonTheme
                                      .colorScheme?.primary ??
                                  kGreenColor)
                              .withOpacity(0.2),
                          size: 50,
                          percent: 0.5,
                          center: const Text(
                            '50%',
                            style: TextStyle(fontSize: 12),
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
                              const SizedBox(
                                width: 600,
                                child: Text(
                                  'Customize how FlutterMatic works for you by setting your preferences and letting us know the way you prefer doing things. This helps using FlutterMatic easier and make the most out of it.',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        HSeparators.normal(),
                        Row(
                          children: <Widget>[
                            SquareButton(
                              size: 30,
                              color: Colors.transparent,
                              icon: const Icon(Icons.arrow_back_ios_rounded,
                                  size: 15),
                              onPressed: () {
                                // TODO(@ZiyadF296): Create back to move between guides.
                              },
                            ),
                            SquareButton(
                              size: 30,
                              color: Colors.transparent,
                              icon: const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 15),
                              onPressed: () {
                                // TODO(@ZiyadF296): Create forward to move between guides.
                              },
                            ),
                          ],
                        ),
                        HSeparators.xLarge(),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: SquareButton(
                      size: 25,
                      color: Colors.transparent,
                      icon: Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: Colors.grey.withOpacity(0.6),
                      ),
                      onPressed: () async {
                        setState(() => _showGuide = false);
                        await SharedPref()
                            .pref
                            .setBool(SPConst.homeShowGuide, false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          snackBarTile(
                            context,
                            'Dismissed guide successfully. You can bring it back in settings.',
                            type: SnackBarType.done,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
