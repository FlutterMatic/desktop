import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SystemRequirementsScreen extends StatefulWidget {
  const SystemRequirementsScreen({Key? key}) : super(key: key);

  @override
  _SystemRequirementsScreenState createState() => _SystemRequirementsScreenState();
}

class _SystemRequirementsScreenState extends State<SystemRequirementsScreen> {
  SyntaxHighlighter? syntaxHighlighter;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<String>(
            future: Future<dynamic>.delayed(const Duration(milliseconds: 150)).then((_) async {
              String s = await rootBundle.loadString('assets/markdown/flutter_requirements.md');
              return s;
            }),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return Column(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  if (snapshot.hasData)
                    Center(
                      child: MarkdownBody(
                        data: snapshot.data!,
                        selectable: true,
                        syntaxHighlighter: syntaxHighlighter,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                          h1: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                          h2: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                          h3: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    const Center(child: CircularProgressIndicator()),
                ],
              );
            }),
      ),
    );
  }
}
