import 'package:flutter/material.dart';
import 'package:manager/components/widgets/ui/markdown_view.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:provider/provider.dart';

class SystemRequirementsScreen extends StatefulWidget {
  const SystemRequirementsScreen({Key? key}) : super(key: key);

  @override
  _SystemRequirementsScreenState createState() =>
      _SystemRequirementsScreenState();
}

class _SystemRequirementsScreenState extends State<SystemRequirementsScreen> {
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
                context.read<ThemeChangeNotifier>().isDarkTheme
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () {
                context.read<ThemeChangeNotifier>().updateTheme(
                    !context.read<ThemeChangeNotifier>().isDarkTheme);
                setState(() {});
              },
            ),
            const Center(
              child: MarkdownComponent(
                  mdFilePath: 'assets/markdown/flutter_requirements.md'),
            ),
          ],
        ),
      ),
    );
  }
}
