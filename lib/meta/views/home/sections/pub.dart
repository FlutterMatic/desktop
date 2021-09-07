import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/meta/utils/shared_pref.dart';

class HomePubSection extends StatelessWidget {
  const HomePubSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SharedPref().pref.getString('App_Build') != 'STABLE'
        ? Column(
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
          )
        : Column(
            children: <Widget>[
              const Text('Pub Packages'),
            ],
          );
  }
}
