// 🎯 Dart imports:
import 'dart:io';

// 🌎 Project imports:
import 'inputs/build.dart';
import 'inputs/release.dart';
import 'inputs/version.dart';
import 'outputs/prints.dart';
import 'utils/app_data.dart';
import 'utils/flutter_build.dart';
import 'utils/spinner.dart';

String dartDefine = '--dart-define';
Future<void> main({List<String>? args}) async {
  try {
    appData.platform = Platform.operatingSystem;
    await versionCollection();
    stopSpinner();
    buildCollection();
    releaseCollection();
    await runBuild();
  } on FormatException catch (fe) {
    printErrorln('❌ Format Exception : ${fe.message}');
  } catch (e) {
    printErrorln(e.toString());
  }
}

Future<void> runBuild() async {
  printInfo('🧹 Clearing previous build files');
  await FlutterMaticBuild.cleanBuild();
  printInfo('⚒️  Started building application EXE file with the info...');
  printInfo('🖥️  Platform : ${appData.platform}');
  printInfo('📝  Version : ${appData.version}');
  printInfo('🏗️  Build : ${appData.buildMode.toString().split('.')[1].toUpperCase()}');
  printInfo('🎥  Release : ${appData.releaseType.toString().split('.')[1].toUpperCase()}');
  await FlutterMaticBuild.build(appData.platform);
  stopSpinner();
  printSuccessln('Finished building EXE file');
  printInfo('⚒️  Started building MSIX file...');
  await FlutterMaticBuild.buildMSIX();
  stopSpinner();
  printSuccess('🏡  Finished building application.');
}
