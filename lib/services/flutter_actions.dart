import 'package:flutter/material.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:process_run/shell.dart';
import 'package:intl/intl.dart';
import 'dart:io';

FlutterActions flutterActions = FlutterActions();

class FlutterActions {
  final Shell _shell = Shell(verbose: false);
  // Create project
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
    try {
      await _shell.cd(projDir!).run(
            'flutter create --org=$projOrg --project-name=$projName --description="$projDesc" --platforms=${android ? 'android' : ''}${(android && ios) ? ',' : ''}${ios ? 'ios' : ''}${(ios && windows) ? ',' : ''}${windows ? 'windows' : ''}${(windows && macos) ? ',' : ''}${macos ? 'macos' : ''}${(macos && web) ? ',' : ''}${web ? 'web' : ''}${(web && linux) ? ',' : ''}${linux ? 'linux' : ''} $projName',
          );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Change channel
  Future<void> changeChannel(String channel) async {
    List<ProcessResult> channelSwap =
        await _shell.run('flutter channel $channel');
    if (!channelSwap[0].stderr.toString().contains('Already on \'$channel\'')) {
      await upgrade();
    }
  }

  // Upgrade Channel
  Future<bool> upgrade() async {
    try {
      await _shell
          .run('flutter upgrade')
          .whenComplete(() => _shell.run('flutter doctor'));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> checkProjects() async {
    List<FileSystemEntity> allContents =
        await Directory(projDir!).list().toList();
    int i = 0;
    if (projs.isNotEmpty) projs.clear();
    if (projsModDate.isNotEmpty) projsModDate.clear();
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
