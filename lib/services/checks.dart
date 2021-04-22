import 'dart:async';
import 'dart:io';
import 'package:flutter_installer/utils/constants.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/which.dart';
import 'package:process_run/shell_run.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckDependencies {
  Shell shell = Shell(
    verbose: false,
    commandVerbose: false,
    commentVerbose: false,
  );
  late SharedPreferences _pref;
  Future<bool> checkFlutter() async {
    _pref = await SharedPreferences.getInstance();
    String? flutterExectutable = await which('flutter');
    if (flutterExectutable != null) {
      if (!_pref.containsKey('flutter_path')) {
        await _pref.setString('flutter_path', flutterExectutable).whenComplete(
              () async => flutterPath = await _pref.getString('flutter_path'),
            );
      } else
        flutterPath = await _pref.getString('flutter_path');
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
    _pref = await SharedPreferences.getInstance();
    String? javaExectutable = await which('java');
    if (javaExectutable != null) {
      if (!_pref.containsKey('java_path')) {
        await _pref.setString('java_path', javaExectutable).whenComplete(
              () async => javaPath = await _pref.getString('java_path'),
            );
      } else
        javaPath = await _pref.getString('java_path');
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
    _pref = await SharedPreferences.getInstance();
    String? vsCodeExectutable = await which('code');
    if (vsCodeExectutable != null) {
      if (!_pref.containsKey('vscode_path')) {
        await _pref
            .setString(
                'vscode_path', vsCodeExectutable.replaceAll('cmd', 'exe'))
            .whenComplete(
              () async => vscPath = await _pref.getString('vscode_path'),
            );
      } else
        vscPath = await _pref.getString('vscode_path');
      ProcessCmd cmd = ProcessCmd('code', ['--version']);
      ProcessResult result = await runCmd(cmd);
      vscodeVersion = result.stdout.split(RegExp(r'[/\n]'))[0].toString();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkVSCInsiders() async {
    _pref = await SharedPreferences.getInstance();
    String? vsCodeInsidersExectutable = await which('code-insiders');
    if (vsCodeInsidersExectutable != null) {
      if (!_pref.containsKey('vscode_insiders_path')) {
        await _pref
            .setString('vscode_insiders_path', vsCodeInsidersExectutable)
            .whenComplete(
              () async => vsCodeInsidersExectutable =
                  await _pref.getString('vscode_insiders_path'),
            );
      } else
        vsCodeInsidersExectutable =
            await _pref.getString('vscode_insiders_path');
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
          .run('dir /b /s /p studio64.exe');
      if (appDataStudios[0].stdout.toString().contains('\\bin\\studio64.exe') &&
          (appDataStudios[0].stdout.toString().contains('Android Studio') ||
              appDataStudios[0].stdout.toString().contains('AndroidStudio'))) {
        if (!_pref.containsKey('android_studio')) {
          await _pref
              .setString(
                  'android_studio',
                  appDataStudios[0]
                      .stdout
                      .toString()
                      .replaceAll(RegExp('[\\n\\r]'), ''))
              .whenComplete(
                () async =>
                    studioPath = await _pref.getString('android_studio'),
              );
        } else
          studioPath = await _pref.getString('android_studio');
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
            if (!_pref.containsKey('android_studio')) {
              await _pref
                  .setString('android_studio',
                      studios[0].stdout.toString().replaceAll('\n', ''))
                  .whenComplete(
                    () async =>
                        studioPath = await _pref.getString('android_studio'),
                  );
            } else
              studioPath = await _pref.getString('android_studio');
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
