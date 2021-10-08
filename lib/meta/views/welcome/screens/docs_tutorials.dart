// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/utils.dart';

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
    setState(() => data = _data.split('------'));
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  void dispose() {
    data = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Stack(
        children: <Widget>[
          if (data == null)
            const Center(child: CircularProgressIndicator())
          else
            ListView.builder(
              itemCount: data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: MarkdownBlock(data: data![index]),
                );
              },
            ),
          Positioned(
            top: 0,
            left: 10,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Positioned(
            top: 0,
            right: 10,
            child: IconButton(
              splashRadius: 1,
              icon: Icon(
                Theme.of(context).isDarkTheme ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              onPressed: () {
                context.read<ThemeChangeNotifier>().updateTheme(!Theme.of(context).isDarkTheme);
                setState(() {});
              },
            ),
          ),
        ],
      )),
    );
  }
}
