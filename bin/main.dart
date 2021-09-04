import 'dart:io';
import 'utils/flutter_build.dart';
import 'inputs/build.dart';
import 'inputs/release.dart';
import 'inputs/version.dart';
import 'utils/app_data.dart';
import 'outputs/prints.dart';
import 'utils/spinner.dart';

String dartDefine = '--dart-define';
Future<void> main({List<String>? args}) async {
  try {
    appData.platform = Platform.operatingSystem;
    versionCollection();
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
  printInfo('⚒️  Started building application with the info...');
  printInfo('🖥️  Platform : ${appData.platform}');
  printInfo('📝 Version : ${appData.version}');
  printInfo('🏗️  Build : ${appData.buildMode}');
  printInfo('🎥 Release : ${appData.releaseType}');
  await startSpinner();
  await FlutterMaticBuild.build(appData.platform);
  stopSpinner();
  printInfo('🏡  Finished building application.');
}
