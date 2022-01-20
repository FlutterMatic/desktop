// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/meta/views/tabs/sections/workflows/elements/tile.dart';

class HomeWorkflowSections extends StatefulWidget {
  const HomeWorkflowSections({Key? key}) : super(key: key);

  @override
  _HomeWorkflowSectionsState createState() => _HomeWorkflowSectionsState();
}

class _HomeWorkflowSectionsState extends State<HomeWorkflowSections> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView.builder(
          itemCount: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, int i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i == 9 ? 0 : 15),
              child: const WorkflowInfoTile(),
            );
          },
        ),
      ),
    );
  }
}
