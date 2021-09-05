# Flutter Requirements

Hello there :smile:

```dart
import 'package:flutter/material.dart';

class Example extends StatefulWidget {
  const Example({ Key? key }) : super(key: key);

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // TODO: Add your widget here
        child: Text('Hello World'),
      ),
    );
  }
}
```