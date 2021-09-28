import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/meta/utils/shared_pref.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({Key? key}) : super(key: key);

  @override
  _HomeSectionState createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  @override
  Widget build(BuildContext context) {
    return SharedPref().pref.getString('App_Build') != 'STABLE'
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Lottie.asset(Assets.ghosts, height: 350),
              VSeparators.normal(),
              const Text(
                'We are still brewing the app',
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
