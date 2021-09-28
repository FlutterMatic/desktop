import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/services/code_highlighter.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

class MarkdownBlock extends StatefulWidget {
  final String? _data;
  final bool wrapWithBox;
  final bool shrinkView;

  const MarkdownBlock({
    Key? key,
    required String? data,
    this.wrapWithBox = true,
    this.shrinkView = false,
  })  : _data = data,
        super(key: key);

  @override
  _MarkdownBlockState createState() => _MarkdownBlockState();
}

class _MarkdownBlockState extends State<MarkdownBlock> {
  String _finalData() {
    if (widget._data == null) {
      return '';
    } else if (widget._data!.contains('img.shields.io')) {
      // We need to convert the tags to png images because we don't support
      // displaying svg in markdown yet.
      return widget._data!.replaceAll('.svg',
          '.png'); // TODO(@yahu1031): Make this .svg extension only replace the ones in the url "img.shields.io" and not anywhere else to .png so that it can be displayed.
    } else {
      return widget._data!;
    }
    // return  widget._data!.replaceAll('https://img.shields.io/pub/v/shared_preferences.svg', 'https://img.shields.io/pub/v/shared_preferences.png'),
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: _finalData(),
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
          ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
        ],
      ),
      styleSheet: MarkdownStyleSheet(
        codeblockPadding: const EdgeInsets.all(5),
        codeblockDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: (context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.grey).withOpacity(0.1),
        ),
        p: TextStyle(
          fontSize: widget.shrinkView ? 16 : 20,
          fontWeight: FontWeight.w400,
          color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black,
        ),
        h1: TextStyle(
          fontSize: widget.shrinkView ? 14 : 24,
          fontWeight: FontWeight.bold,
          color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black,
        ),
        h2: TextStyle(
          fontSize: widget.shrinkView ? 13 : 20,
          fontWeight: FontWeight.bold,
          color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black,
        ),
        h3: TextStyle(
          fontSize: widget.shrinkView ? 12 : 18,
          fontWeight: FontWeight.bold,
          color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black,
        ),
        h4: TextStyle(
          fontSize: widget.shrinkView ? 11 : 16,
          fontWeight: FontWeight.bold,
          color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black,
        ),
        h5: TextStyle(
          fontSize: widget.shrinkView ? 10 : 14,
          fontWeight: FontWeight.bold,
          color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black,
        ),
        h6: TextStyle(
          fontSize: widget.shrinkView ? 9 : 12,
          fontWeight: FontWeight.bold,
          color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black,
        ),
        code: TextStyle(
          fontSize: 16,
          color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black,
          backgroundColor: Colors.grey.withOpacity(0.2),
        ),
        img: const TextStyle(color: Colors.transparent),
        checkbox: const TextStyle(fontSize: 16),
      ),
    );
  }
}
