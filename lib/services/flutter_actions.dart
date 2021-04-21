import 'dart:io';

import 'package:flutter_installer/utils/constants.dart';
import 'package:process_run/shell.dart';
import 'package:intl/intl.dart';

class FlutterActions {
  Shell shell = Shell();
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
    List<ProcessResult> channelSwap =
        await shell.run('flutter channel $channel');
    if (!channelSwap[0].stderr.toString().contains('Already on \'$channel\'')) {
      await upgrade();
    }
  }

//Upgrade Channel
  Future<bool> upgrade() async {
    try {
      await shell
          .run('flutter upgrade')
          .whenComplete(() => shell.run('flutter doctor'));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> checkProjects() async {
    List<FileSystemEntity> allContents =
        await Directory(projDir!).list().toList();
    int i = 0;
    while (i < allContents.length) {
      if (allContents[i]
          .runtimeType
          .toString()
          .replaceAll('_', '')
          .contains('Directory')) {
        bool fileExist =
            await File('${allContents[i].path}\\lib\\main.dart').exists();
        if (fileExist) {
          FileStat projDirStats = await Directory(allContents[i].path).stat();
          DateTime mod = projDirStats.modified;
          String modDate = DateFormat.yMMMd().format(mod);
          String projDirName = allContents[i].path.replaceAll('$projDir\\', '');
          projs.add(projDirName);
          projsModDate.add(modDate);
        }
      }
      i++;
    }
  }
}
