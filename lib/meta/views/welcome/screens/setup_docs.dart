// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/components/widgets/ui/spinner.dart';
import 'package:manager/components/widgets/ui/tab_view.dart';
import 'package:manager/core/libraries/services.dart';

class SetupDocsScreen extends StatefulWidget {
  const SetupDocsScreen({Key? key}) : super(key: key);

  @override
  _SetupDocsScreenState createState() => _SetupDocsScreenState();
}

class _SetupDocsScreenState extends State<SetupDocsScreen> {
  bool _isLoading = true;
  final List<TabViewObject> _tabs = <TabViewObject>[];

  static const List<String> _docsNames = <String>[
    'flutter.md',
    'editors.md',
    'git.md',
    'java.md',
  ];

  Future<void> _loadData() async {
    try {
      for (String name in _docsNames) {
        String _fileContent =
            await rootBundle.loadString('assets/markdown/setup_docs/$name');

        setState(() {
          _tabs.add(
            TabViewObject(
              // Also capitalizes the first letter of each word, replace
              // underscores with spaces.
              name
                  .split('\\')
                  .last
                  .split('.')
                  .first
                  .replaceAll('_', ' ')
                  .split(' ')
                  .map((String _word) =>
                      _word.substring(0, 1).toUpperCase() + _word.substring(1))
                  .join(' '),
              MarkdownBody(
                selectable: true,
                data: _fileContent,
                extensionSet: md.ExtensionSet(
                  md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                  <md.InlineSyntax>[
                    md.EmojiSyntax(),
                    ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
                  ],
                ),
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
              ),
            ),
          );
        });
      }

      setState(() => _isLoading = false);
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to load setup docs $_',
          stackTraces: s);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'Failed to load setup docs. Please try again later.',
          type: SnackBarType.error,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      width: 800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Setup Documentation'),
          VSeparators.normal(),
          if (_isLoading)
            const Center(child: Spinner())
          else
            TabViewWidget(tabs: _tabs),
        ],
      ),
    );
  }
}
