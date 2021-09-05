import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/markdown_view.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/shared_pref.dart';

class ChangelogAboutSection extends StatelessWidget {
  const ChangelogAboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabViewTabHeadline(
      title: 'Changelog',
      allowContentScroll: false,
      content: <Widget>[
        infoWidget(context,
            '- Version: ${SharedPref().pref.getString('App_Version')} (${SharedPref().pref.getString('App_Build')!.toUpperCase()}) \n- $osName - $osVersion'),
        VSeparators.normal(),
        const Expanded(
          child: SingleChildScrollView(
            child: MarkdownComponent(mdFilePath: 'changelog.md'),
          ),
        ),
      ],
    );
  }
}
