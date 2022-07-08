// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:markdown/markdown.dart' as md;

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';

class ChangelogAboutSection extends StatefulWidget {
  const ChangelogAboutSection({Key? key}) : super(key: key);

  @override
  _ChangelogAboutSectionState createState() => _ChangelogAboutSectionState();
}

class _ChangelogAboutSectionState extends State<ChangelogAboutSection> {
  bool _loading = true;
  final List<String> _data = <String>[];

  Future<void> _loadData() async {
    String data = await rootBundle.loadString('CHANGELOG.md');

    List<String> releases = <String>[];
    String currentRelease = '';

    bool _isReleaseLine(String line) {
      line.trim();

      if (!line.startsWith('### v')) {
        return false;
      }

      // Split the line into parts.
      List<String> parts = line.split(' ');

      // Has to be four parts.
      if (parts.length != 4) {
        return false;
      }

      // See if the first part is a version number.
      List<String> versionParts = parts[1].split('.');

      for (String part in versionParts) {
        if (part.startsWith('v')) {
          part = part.substring(1);
        }

        if (part.isEmpty) {
          return false;
        }

        if (int.tryParse(part) == null) {
          return false;
        }
      }

      // Make sure that the last part is a release type.
      List<String> releaseTypes = <String>['beta', 'alpha', 'stable'];

      if (!releaseTypes.contains(parts[3].toLowerCase())) {
        return false;
      }

      return true;
    }

    data.split('\n').forEach((String line) {
      // Splits each release chunks into a list of lines.
      if (_isReleaseLine(line)) {
        releases.add(currentRelease);
        currentRelease = line;
      } else {
        currentRelease += line;
      }
    });

    releases.add(currentRelease);

    setState(() {
      _loading = false;
      _data.addAll(releases);
    });
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: Spinner());
    } else {
      return Consumer(
        builder: (_, ref, __) {
          ThemeState themeState = ref.watch(themeStateController);

          return ListView.builder(
            shrinkWrap: true,
            itemCount: _data.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundContainer(
                  child: MarkdownBody(
                    data: _data[index],
                    selectable: true,
                    styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
                    extensionSet: md.ExtensionSet(
                      md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                      <md.InlineSyntax>[
                        md.EmojiSyntax(),
                        ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
                      ],
                    ),
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: themeState.isDarkTheme
                            ? Colors.grey[100]
                            : Colors.grey[900],
                      ),
                      h1: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: themeState.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                      h2: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: themeState.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                      h3: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: themeState.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }
}
