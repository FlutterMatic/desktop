import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/shared_pref.dart';

class ChangelogAboutSection extends StatelessWidget {
  const ChangelogAboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Changelog'),
        VSeparators.normal(),
        infoWidget(context,
            '- Version: ${SharedPref().prefs.getString('App_Version')} (${SharedPref().prefs.getString('App_Build')!.toUpperCase()}) \n- $osName - $osVersion'),
        VSeparators.normal(),
        //TODO(yahu1031): Add markdown for changelog in about page.
      ],
    );
  }
}
