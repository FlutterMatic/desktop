// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:lottie/lottie.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/meta/utils/shared_pref.dart';

class HomePubSection extends StatelessWidget {
  const HomePubSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (SharedPref().pref.getString('App_Build') != 'STABLE') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Lottie.asset(Assets.packages, height: 250),
          VSeparators.normal(),
          const Text(
            'We are packing the data',
            style: TextStyle(fontSize: 20),
          ),
        ],
      );
    } else {
      return Column(
        children: const <Widget>[
          Text('Pub Packages'),
        ],
      );
    }
  }
}
