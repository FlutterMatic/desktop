// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/components.dart';

class SystemRequirementsScreen extends StatefulWidget {
  const SystemRequirementsScreen({Key? key}) : super(key: key);

  @override
  _SystemRequirementsScreenState createState() =>
      _SystemRequirementsScreenState();
}

class _SystemRequirementsScreenState extends State<SystemRequirementsScreen> {
  List<String?>? data;

  Future<void> _loadData() async {
    String _data =
        await rootBundle.loadString('assets/markdown/flutter_requirements.md');
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
                  child: Container(
                    color: Colors.white.withOpacity(0.1),
                    padding: const EdgeInsets.all(16),
                    width: 750,
                    child: MarkdownBlock(
                      data: data![index],
                    ),
                  ),
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
        ],
      )),
    );
  }
}
