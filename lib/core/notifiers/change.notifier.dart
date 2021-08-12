// import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:flutter/material.dart';
// import 'package:manager/app/constants/enum.dart';
// import 'package:manager/core/models/flutter_sdk.model.dart';
// import 'package:manager/core/models/fluttermatic.model.dart';
// import 'package:manager/core/services/checks/flutter.check.dart';
// import 'package:manager/core/services/checks/git.check.dart';
// import 'package:manager/core/services/checks/java.check.dart';
// import 'package:manager/core/services/checks/adb.check.dart';
// import 'package:manager/core/services/checks/studio.check.dart';
// import 'package:manager/core/services/checks/vsc.check.dart';
// import 'package:provider/provider.dart';

// class MainChecksNotifier extends ValueNotifier<ApplicationCheckType> {
//   MainChecksNotifier() : super(ApplicationCheckType.FLUTTER_CHECK);

//   Future<void> startChecking(BuildContext context, FluttermaticAPI? api,
//       {FlutterSDK? sdk}) async {
//     await context.read<FlutterChangeNotifier>().checkFlutter(context, sdk);
//     value = ApplicationCheckType.JAVA_CHECK;
//     await context.read<JavaChangeNotifier>().checkJava(context, api);
//     value = ApplicationCheckType.GIT_CHECK;
//     await context.read<GitChangeNotifier>().checkGit(context, api);
//     value = ApplicationCheckType.ADB_CHECK;
//     await context.read<ADBChangeNotifier>().checkADB(context, api);
//     value = ApplicationCheckType.ANDROID_STUDIO_CHECK;
//     await context
//         .read<AndroidStudioChangeNotifier>()
//         .checkAStudio(context, api);
//     value = ApplicationCheckType.VSC_CHECK;
//     await context.read<VSCodeChangeNotifier>().checkVSCode(context, api);
//     value = ApplicationCheckType.DONE;
//     appWindow.minSize = const Size(600, 700);
//     appWindow.size = const Size(600, 700);
//     appWindow.maximize();
//   }
// }
