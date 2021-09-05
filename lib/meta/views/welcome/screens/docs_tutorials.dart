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
  List<String?>? data;

  Future<void> _loadData() async {
    String _data = await rootBundle.loadString('assets/markdown/flutter_requirements.md');
    setState(() {
      data = _data.split('------');
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
    data = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Stack(
        children: <Widget>[
          data == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Center(
                      child: ContentBlocks(
                        data: data![index],
                      ),
                    );
                  },
                ),
          Positioned(
            top: 0,
            left: 10,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Positioned(
            top: 0,
            right: 10,
            child: IconButton(
              splashRadius: 1,
              icon: Icon(
                context.read<ThemeChangeNotifier>().isDarkTheme ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              onPressed: () {
                context.read<ThemeChangeNotifier>().updateTheme(!context.read<ThemeChangeNotifier>().isDarkTheme);
                setState(() {});
              },
            ),
          ),
        ],
      )),
    );
  }
}

class ContentBlocks extends StatefulWidget {
  const ContentBlocks({
    Key? key,
    required String? data,
  })  : _data = data,
        super(key: key);

  final String? _data;

  @override
  _ContentBlocksState createState() => _ContentBlocksState();
}

class _ContentBlocksState extends State<ContentBlocks> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.black54 : Colors.grey[300],
        ),
        child: MarkdownBody(
          data: widget._data!,
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
            codeblockDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color:
                  context.read<ThemeChangeNotifier>().isDarkTheme ? const Color(0xFF282C34) : const Color(0xFFF3F3F3),
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
            img: const TextStyle(),
          ),
        ),
      ),
    );
  }
}
