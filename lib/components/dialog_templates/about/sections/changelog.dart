import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/markdown_view.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/shared_pref.dart';

class ChangelogAboutSection extends StatelessWidget {
  const ChangelogAboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TabViewTabHeadline(
      title: 'Changelog',
      content: <Widget>[
        MarkdownComponent(mdFilePath: 'changelog.md'),
      ],
    );
  }
}
