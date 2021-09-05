import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/services/code_highlighter.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
// hi
class SystemRequirementsScreen extends StatefulWidget {
  const SystemRequirementsScreen({Key? key}) : super(key: key);

  @override
  _SystemRequirementsScreenState createState() => _SystemRequirementsScreenState();
}

class _SystemRequirementsScreenState extends State<SystemRequirementsScreen> {
  String? _data;

  Future<void> _loadData() async {
    String data = await rootBundle.loadString('assets/markdown/flutter_requirements.md');
    setState(() {
      _data = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _data = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          IconButton(
            splashRadius: 1,
            icon: Icon(
              context.read<ThemeChangeNotifier>().isDarkTheme ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              context.read<ThemeChangeNotifier>().updateTheme(!context.read<ThemeChangeNotifier>().isDarkTheme);
              setState(() {});
            },
          ),
          Center(
            child: _data == null
                ? const CircularProgressIndicator()
                : MarkdownBody(
                    data: _data!,
                    selectable: true,
                    styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
                    syntaxHighlighter: DartSyntaxHighlighter(
                      context.read<ThemeChangeNotifier>().isDarkTheme
                          ? SyntaxHighlighterStyle.darkThemeStyle()
                          : SyntaxHighlighterStyle.lightThemeStyle(),
                    ),
                    extensionSet: md.ExtensionSet(
                      md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                      <md.InlineSyntax>[md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
                    ),
                    styleSheet: MarkdownStyleSheet(
                      codeblockPadding: const EdgeInsets.all(8),
                      codeblockAlign: WrapAlignment.start,
                      codeblockDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: context.read<ThemeChangeNotifier>().isDarkTheme
                            ? const Color(0xFF282C34)
                            : const Color(0xFFF3F3F3),
                      ),
                      p: const TextStyle(fontSize: 46.0, fontWeight: FontWeight.w400),
                      h1: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black,
                      ),
                      h2: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      h3: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      code: const TextStyle(fontSize: 16.0, fontFamily: 'VictorMono'),
                    ),
                  ),
          ),
        ],
      )),
    );
  }
}
