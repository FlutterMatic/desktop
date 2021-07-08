import 'package:flutter/material.dart';

class JavaNotifier extends ValueNotifier<String> {
  JavaNotifier([String value = 'Checking java']) : super(value);
  Future<void> javaCheck() async {
    value = 'Java found';
  }
}

class JavaChangeNotifier extends JavaNotifier {
  JavaChangeNotifier() : super('Checking Java');
}
