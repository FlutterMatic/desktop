// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/stress_relief.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';

class HomeToolErrorTile extends StatelessWidget {
  final String toolName;
  
  const HomeToolErrorTile({
    Key? key,
    required this.toolName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundContainer(
      borderColor: Colors.black,
      color: AppTheme.errorColor,
      child: Column(
        children: <Widget>[
          const StressReliefWidget(),
          VSeparators.normal(),
          SvgPicture.asset(Assets.error, color: Colors.white),
          VSeparators.normal(),
          Text(
            'Couldn\'t load $toolName',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          VSeparators.small(),
          Text(
            'For some reason, we were not able to load $toolName information. Please try again later or file an issue on GitHub if the problem persists.',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          VSeparators.normal(),
          const StressReliefWidget(),
        ],
      ),
    );
  }
}
