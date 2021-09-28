import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/meta/utils/shared_pref.dart';

class HomeProjectSection extends StatefulWidget {
  const HomeProjectSection({Key? key}) : super(key: key);

  @override
  _HomeProjectSectionState createState() => _HomeProjectSectionState();
}

class _HomeProjectSectionState extends State<HomeProjectSection> {
  @override
  Widget build(BuildContext context) {
    return SharedPref().pref.getString('App_Build') != 'STABLE'
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Lottie.asset(Assets.codingLottie, height: 250),
              VSeparators.normal(),
              const Text(
                'Still in development stage',
                style: TextStyle(fontSize: 20),
              ),
            ],
          )
        : Column(
            children: const <Widget>[
              Text('Pub Packages'),
            ],
          );
  }
}
