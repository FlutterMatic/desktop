import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/notifiers/flutter.notifier.dart';
import 'package:manager/core/notifiers/java.notifier.dart';
import 'package:provider/provider.dart';

class MainChecksNotifier extends ValueNotifier<ApplicationCheckType> {
  MainChecksNotifier() : super(ApplicationCheckType.FLUTTER_CHECK);

  Future<void> startChecking(BuildContext context) async {
    await context.read<FlutterChangeNotifier>().flutterCheck();
    value = ApplicationCheckType.JAVA_CHECK;
    await context.read<JavaChangeNotifier>().javaCheck();
  }
}