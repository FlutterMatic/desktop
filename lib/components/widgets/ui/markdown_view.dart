import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/components/widgets/ui/spinner.dart';
import 'package:provider/provider.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:manager/core/notifiers/theme.notifier.dart';
import 'package:manager/core/services/code_highlighter.dart';

class MarkdownComponent extends StatefulWidget {
  final String mdFilePath;

  const MarkdownComponent({Key? key, required this.mdFilePath})
      : super(key: key);

  @override
  _MarkdownComponentState createState() => _MarkdownComponentState();
}

class _MarkdownComponentState extends State<MarkdownComponent> {
  String? _data;

  Future<void> _loadData() async {
    String data = await rootBundle.loadString(widget.mdFilePath);
    setState(() => _data = data);
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme = Theme.of(context);
    if (_data == null) {
      return RoundContainer(
        color: currentTheme.accentColor.withOpacity(0.2),
        child: const Center(child: Spinner()),
      );
    } else {
      return MarkdownBody(
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
          <md.InlineSyntax>[
            md.EmojiSyntax(),
            ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
          ],
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
            color: context.read<ThemeChangeNotifier>().isDarkTheme
                ? Colors.white
                : Colors.black,
          ),
          h2: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          h3: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          code: const TextStyle(fontSize: 16.0, fontFamily: 'VictorMono'),
        ),
      );
    }
  }
}
