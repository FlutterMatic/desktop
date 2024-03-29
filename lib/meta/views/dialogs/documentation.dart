// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/components/widgets/ui/tab_view.dart';
import 'package:fluttermatic/core/services/logs.dart';

enum DocTabs { setup, newProjects, workflows }

class DocumentationDialog extends StatefulWidget {
  final DocTabs? tab;

  const DocumentationDialog({Key? key, this.tab}) : super(key: key);

  @override
  _DocumentationDialogState createState() => _DocumentationDialogState();
}

class _DocumentationDialogState extends State<DocumentationDialog> {
  bool _isLoading = true;
  final List<TabViewObject> _tabs = <TabViewObject>[];

  static const List<String> _docsNames = <String>[
    'setup',
    'new_projects',
    'workflows',
  ];

  Future<void> _loadData() async {
    try {
      for (String name in _docsNames) {
        String fileContent =
            await rootBundle.loadString('assets/documentation/$name.md');

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
                  .map((String word) =>
                      word.substring(0, 1).toUpperCase() + word.substring(1))
                  .join(' '),
              SingleChildScrollView(
                child: MarkdownBody(
                  onTapLink: (String txt, String? href, String title) {
                    try {
                      launchUrl(Uri.parse(txt));
                    } catch (e, s) {
                      logger.file(LogTypeTag.error,
                          'Couldn\'t open documentation referenced link: $txt - $href - $title.',
                          error: e, stackTrace: s);

                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarTile(
                          context,
                          'Sorry, couldn\'t open this link.',
                          type: SnackBarType.error,
                        ),
                      );
                    }
                  },
                  selectable: true,
                  data: fileContent,
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
            ),
          );
        });
      }

      setState(() => _isLoading = false);
    } catch (e, s) {
      await logger.file(LogTypeTag.error, 'Failed to load documentation.',
          error: e, stackTrace: s);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'Failed to load documentation. Please try again later or report this issue if it persists.',
            type: SnackBarType.error,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  String? _getTab() {
    switch (widget.tab) {
      case DocTabs.setup:
        return 'Setup';
      case DocTabs.newProjects:
        return 'New Projects';
      case DocTabs.workflows:
        return 'Workflows';
      default:
        return null;
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
      height: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Documentation'),
          if (_isLoading)
            const Center(child: Spinner())
          else
            TabViewWidget(defaultPage: _getTab(), tabs: _tabs, height: 520),
        ],
      ),
    );
  }
}
