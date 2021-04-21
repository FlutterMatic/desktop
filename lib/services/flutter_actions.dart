import 'package:flutter_installer/utils/constants.dart';
import 'package:process_run/shell_run.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlutterActions {
  Shell shell = Shell();
  late SharedPreferences _pref;

  //Create project
  Future<void> flutterCreate(
    String projName,
    String projDesc,
    String projOrg, {
    required bool android,
    required bool windows,
    required bool ios,
    required bool macos,
    required bool linux,
    required bool web,
  }) async {
    await shell.cd(projDir!).run(
          'flutter create --org=$projOrg --project-name=$projName --description="$projDesc" --platforms=${android ? 'android' : ''}${(android && ios) ? ',' : ''}${ios ? 'ios' : ''}${(ios && windows) ? ',' : ''}${windows ? 'windows' : ''}${(windows && macos) ? ',' : ''}${macos ? 'macos' : ''}${(macos && web) ? ',' : ''}${web ? 'web' : ''}${(web && linux) ? ',' : ''}${linux ? 'linux' : ''} $projName',
        );
  }

  //Change channel
  Future<void> changeChannel(String channel) async {
    await shell
        .run('flutter channel ${channel.toLowerCase()}')
        .then((value) => upgrade());
  }

  //Upgrade Channel
  Future<bool> upgrade() async {
    try {
      await shell.run('flutter upgrade');
      await shell.run('flutter doctor');
      return true;
    } catch (_) {
      return false;
    }
  }
}
