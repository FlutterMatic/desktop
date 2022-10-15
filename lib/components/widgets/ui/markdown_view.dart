// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;

// 🌎 Project imports:
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/code_highlighter.dart';

class MarkdownBlock extends StatelessWidget {
  final String? data;
  final bool wrapWithBox;
  final bool shrinkView;

  const MarkdownBlock({
    Key? key,
    required this.data,
    this.wrapWithBox = true,
    this.shrinkView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

        return MarkdownBody(
          data: data ?? 'Nothing to show',
          selectable: true,
          styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
          syntaxHighlighter: DartSyntaxHighlighter(
            themeState.darkTheme
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
              color: (themeState.darkTheme ? Colors.white : Colors.grey)
                  .withOpacity(0.1),
            ),
            p: TextStyle(
              fontSize: shrinkView ? 16 : 20,
              fontWeight: FontWeight.w400,
              color: themeState.darkTheme ? Colors.white : Colors.black,
            ),
            h1: TextStyle(
              fontSize: shrinkView ? 14 : 24,
              fontWeight: FontWeight.bold,
              color: themeState.darkTheme ? Colors.white : Colors.black,
            ),
            h2: TextStyle(
              fontSize: shrinkView ? 13 : 20,
              fontWeight: FontWeight.bold,
              color: themeState.darkTheme ? Colors.white : Colors.black,
            ),
            h3: TextStyle(
              fontSize: shrinkView ? 12 : 18,
              fontWeight: FontWeight.bold,
              color: themeState.darkTheme ? Colors.white : Colors.black,
            ),
            h4: TextStyle(
              fontSize: shrinkView ? 11 : 16,
              fontWeight: FontWeight.bold,
              color: themeState.darkTheme ? Colors.white : Colors.black,
            ),
            h5: TextStyle(
              fontSize: shrinkView ? 10 : 14,
              fontWeight: FontWeight.bold,
              color: themeState.darkTheme ? Colors.white : Colors.black,
            ),
            h6: TextStyle(
              fontSize: shrinkView ? 9 : 12,
              fontWeight: FontWeight.bold,
              color: themeState.darkTheme ? Colors.white : Colors.black,
            ),
            code: TextStyle(
              fontSize: 16,
              color: themeState.darkTheme ? Colors.white : Colors.black,
              backgroundColor: Colors.grey.withOpacity(0.2),
            ),
            img: const TextStyle(color: Colors.transparent),
            checkbox: const TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }
}
