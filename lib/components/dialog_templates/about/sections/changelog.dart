// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

// 🌎 Project imports:
import 'package:fluttermatic/core/libraries/widgets.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';

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

    List<String> _releases = <String>[];
    String _currentRelease = '';

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
      List<String> _versionParts = parts[1].split('.');

      for (String part in _versionParts) {
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
      List<String> _releaseTypes = <String>['beta', 'alpha', 'stable'];

      if (!_releaseTypes.contains(parts[3].toLowerCase())) {
        return false;
      }

      return true;
    }

    data.split('\n').forEach((String line) {
      // Splits each release chunks into a list of lines.
      if (_isReleaseLine(line)) {
        _releases.add(_currentRelease);
        _currentRelease = line;
      } else {
        _currentRelease += line;
      }
    });

    _releases.add(_currentRelease);

    setState(() {
      _loading = false;
      _data.addAll(_releases);
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
      return ListView.builder(
        shrinkWrap: true,
        itemCount: _data.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RoundContainer(
              color: Colors.blueGrey.withOpacity(0.2),
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
                    color: Theme.of(context).isDarkTheme
                        ? Colors.grey[100]
                        : Colors.grey[900],
                  ),
                  h1: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).isDarkTheme
                        ? Colors.white
                        : Colors.black,
                  ),
                  h2: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).isDarkTheme
                        ? Colors.white
                        : Colors.black,
                  ),
                  h3: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).isDarkTheme
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
