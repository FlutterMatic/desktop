// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

// 🌎 Project imports:
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/app_theme.dart';

class ChangelogAboutSection extends StatefulWidget {
  const ChangelogAboutSection({Key? key}) : super(key: key);

  @override
  _ChangelogAboutSectionState createState() => _ChangelogAboutSectionState();
}

class _ChangelogAboutSectionState extends State<ChangelogAboutSection> {
  List<String>? _data;

  Future<void> _loadData() async {
    String data = await rootBundle.loadString('changelog.md');
    setState(() => _data = data.split('<!-- Old Release -->'));
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return const Center(child: Spinner());
    } else {
      return SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * (_data!.length / 7.2),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: _data?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7.0),
                child: RoundContainer(
                  color: Theme.of(context).isDarkTheme ? Colors.blueGrey.withOpacity(0.2) : Colors.grey[200],
                  child: MarkdownBody(
                    data: _data![index],
                    selectable: true,
                    styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
                    extensionSet: md.ExtensionSet(
                      md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                      <md.InlineSyntax>[md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
                    ),
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).isDarkTheme ? Colors.grey[100] : Colors.grey[900],
                        fontFamily: 'LexendDeca',
                      ),
                      h1: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).isDarkTheme ? Colors.white : Colors.black,
                        fontFamily: 'LexendDeca',
                      ),
                      h2: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).isDarkTheme ? Colors.white : Colors.black,
                        fontFamily: 'LexendDeca',
                      ),
                      h3: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).isDarkTheme ? Colors.white : Colors.black,
                        fontFamily: 'LexendDeca',
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }
}
