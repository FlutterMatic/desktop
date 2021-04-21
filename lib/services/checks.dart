import 'dart:async';
import 'dart:io';
import 'package:flutter_installer/utils/constants.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/which.dart';
import 'package:process_run/shell_run.dart';

class CheckDependencies {
  Shell shell = Shell();
  Future<bool> checkFlutter() async {
    String? flutterExectutable = await which('flutter');
    if (flutterExectutable != null) {
      ProcessCmd cmd = ProcessCmd('flutter', ['--version']);
      ProcessResult result = await runCmd(cmd);
      flutterVersion = result.stdout.split(' ')[1].toString();
      flutterChannel = result.stdout.split(' ')[4].toString();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkJava() async {
    String? javaExectutable = await which('java');
    if (javaExectutable != null) {
      ProcessResult result = await runCmd(ProcessCmd('java', ['-version']));
      javaVersion = result.stderr
          .split('\n')[0]
          .split(' ')[2]
          .toString()
          .replaceAll('"', '');
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkVSC() async {
    String? vsCodeExectutable = await which('code');
    if (vsCodeExectutable != null) {
      ProcessCmd cmd = ProcessCmd('code', ['--version']);
      ProcessResult result = await runCmd(cmd);
      vscodeVersion = result.stdout.split(RegExp(r'[/\n]'))[0].toString();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkVSCInsiders() async {
    String? vsCodeInsidersExectutable = await which('code-insiders');
    if (vsCodeInsidersExectutable != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkAndroidStudios() async {
    List<ProcessResult> userProfile = await shell.run('echo %USERPROFILE%');
    try {
      List<ProcessResult> appDataStudios = await shell
          .cd('${userProfile[0].stdout.toString().replaceAll(RegExp(r'[/"/\n]'), '').replaceAll('\\', '/').trim()}/AppData/Local/JetBrains/')
          .run('dir /b /s /p studio.exe');
      if (appDataStudios[0].stdout.toString().contains('\\bin\\studio.exe') &&
          (appDataStudios[0].stdout.toString().contains('Android Studio') ||
              appDataStudios[0].stdout.toString().contains('AndroidStudio'))) {
        return true;
      } else {
        return false;
      }
    } on ShellException catch (err) {
      if (err.message.toString().contains('The directory name is invalid.')) {
        try {
          List<ProcessResult> studios = await shell
              .cd('C:/Program\ Files/Android/Android\ Studio/')
              .run('dir /b /s /p studio.exe');
          if (studios[0].stdout.toString().contains('\\bin\\studio.exe') &&
              (studios[0].stdout.toString().contains('Android Studio') ||
                  studios[0].stdout.toString().contains('AndroidStudio'))) {
            return true;
          } else {
            return false;
          }
        } on ShellException catch (_) {
          return false;
        } catch (e) {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkXCode() async => true;
}
