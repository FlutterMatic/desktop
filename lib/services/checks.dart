import 'dart:async';
import 'dart:io';
import 'package:process_run/which.dart';
import 'package:process_run/shell_run.dart';

class CheckDependencies {
  Shell shell = Shell();
  Future<bool> checkFlutter() async {
    String? flutterExectutable = await which('flutter');
    if (flutterExectutable != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkJava() async {
    String? javaExectutable = await which('java');
    if (javaExectutable != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkVSC() async {
    String? vsCodeExectutable = await which('code');
    if (vsCodeExectutable != null) {
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
          .cd('${userProfile[0].stdout.toString().replaceAll(RegExp(r'[/"/\n]'), '').replaceAll('\\', '/').trim()}/AppData/Local/JetBrains/Toolbox/apps/AndroidStudio/')
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
