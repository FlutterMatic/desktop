import 'package:flutter/material.dart';

class HomePubSection extends StatelessWidget {
  const HomePubSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Pub Packages'),
      ],
    );
  }
}
