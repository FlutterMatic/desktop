import 'package:flutter/material.dart';
import 'package:flutter_installer/services/other.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/which.dart';
import 'package:process_run/shell_run.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';

class Win32Checks {
  Shell shell = Shell(
    verbose: false,
    commandVerbose: false,
    commentVerbose: false,
    runInShell: true,
  );
  late SharedPreferences _pref;
  Future<bool> checkFlutter() async {
    _pref = await SharedPreferences.getInstance();
    debugPrint('Flutter checking');
    String? flutterExectutable = await which('flutter');
    if (flutterExectutable != null) {
      if (!_pref.containsKey('flutter_path')) {
        await _pref.setString('flutter_path', flutterExectutable).whenComplete(
              () async => flutterPath = _pref.getString('flutter_path'),
            );
      } else {
        flutterPath = _pref.getString('flutter_path');
      }
      ProcessCmd cmd = ProcessCmd('flutter', ['--version']);
      ProcessResult result = await runCmd(cmd);
      flutterVersion = result.stdout.split(' ')[1].toString();
      flutterChannel = result.stdout.split(' ')[4].toString();
      debugPrint('Flutter checking Done');
      return true;
    } else {
      debugPrint('Flutter checking Done');
      return false;
    }
  }

  Future<bool> checkJava() async {
    _pref = await SharedPreferences.getInstance();
    debugPrint('Java checking');

    String? javaExectutable = await which('java');
    if (javaExectutable != null) {
      if (!_pref.containsKey('java_path')) {
        await _pref.setString('java_path', javaExectutable).whenComplete(
              () async => javaPath = _pref.getString('java_path'),
            );
      } else {
        javaPath = _pref.getString('java_path');
      }
      ProcessResult result = await runCmd(ProcessCmd('java', ['-version']));
      javaVersion = result.stderr
          .split('\n')[0]
          .split(' ')[2]
          .toString()
          .replaceAll('"', '');
      debugPrint('Java checking Done');
      return true;
    } else {
      debugPrint('Java checking Done');
      return false;
    }
  }

  Future<bool> checkVSC() async {
    _pref = await SharedPreferences.getInstance();
    debugPrint('VSC checking ');

    String? vsCodeExectutable = await which('code');
    if (vsCodeExectutable != null) {
      if (!_pref.containsKey('vscode_path')) {
        await _pref
            .setString(
                'vscode_path',
                vsCodeExectutable
                    .replaceAll('\\bin', '')
                    .replaceAll('.cmd', '.exe'))
            .whenComplete(
              () async => vscPath = _pref.getString('vscode_path'),
            );
      } else {
        vscPath = _pref.getString('vscode_path');
      }
      ProcessCmd cmd = ProcessCmd('code', ['--version']);
      ProcessResult result = await runCmd(cmd);
      vscodeVersion = result.stdout.split(RegExp(r'[/\n]'))[0].toString();
      debugPrint('VSC checking Done');
      return true;
    } else {
      debugPrint('VSC checking Done');
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
                  _pref.getString('vscode_insiders_path'),
            );
      } else {
        vsCodeInsidersExectutable = _pref.getString('vscode_insiders_path');
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkAndroidStudios() async {
    debugPrint('AS checking ');
    _pref = await SharedPreferences.getInstance();
    List<ProcessResult> userProfile = await shell.run('echo %localappdata%');
    try {
      List<ProcessResult> appDataStudios = await shell
          .cd('${userProfile[0].stdout.toString().replaceAll(RegExp(r'[/"/\n]'), '').replaceAll('\\', '/').trim()}/JetBrains/')
          .run('dir /b /s /p studio64.exe');
      List<FileSystemEntity> studioVersion = await Directory(
              '${userProfile[0].stdout.toString().replaceAll(RegExp(r'[/"/\n]'), '').replaceAll('\\', '/').trim()}/Google/')
          .list()
          .toList();
      androidSVersion = studioVersion.first
          .toString()
          .split('/')
          .last
          .replaceAll('\'', '')
          .replaceAll('AndroidStudio', '');
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
            () async {
              studioPath = _pref.getString('android_studio');
              try {
                await setPath(studioPath!
                    .replaceAll('studio64.exe', '')
                    .replaceAll('"', ''));
                await _pref.setBool('studio64', true);
              } catch (e) {
                debugPrint(e.toString());
              }
            },
          );
        } else {
          studioPath = _pref.getString('android_studio');
          String? std = await which('studio64');
          if (_pref.getBool('studio64') == false) {
            if (std == null) {
              try {
                await setPath(studioPath!
                    .replaceAll('studio64.exe', '')
                    .replaceAll('"', ''));
                await _pref.setBool('studio64', true);
              } catch (e) {
                debugPrint(e.toString());
              }
            }
          }
        }
        debugPrint('AS checking Done');
        return true;
      } else {
        debugPrint('AS checking Done');
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
                () async {
                  studioPath = _pref.getString('android_studio');
                  if (_pref.getBool('studio64') == false) {
                    try {
                      await setPath(studioPath!
                          .replaceAll('studio64.exe', '')
                          .replaceAll('"', ''));
                      await _pref.setBool('studio64', true);
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  }
                },
              );
            } else {
              studioPath = _pref.getString('android_studio');
              if (_pref.getBool('studio64') == false) {
                if (await which('studio64') == null) {
                  try {
                    await setPath(studioPath!
                        .replaceAll('studio64.exe', '')
                        .replaceAll('"', ''));
                    await _pref.setBool('studio64', true);
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                }
              }
            }
            debugPrint('AS checking Done');
            return true;
          } else {
            debugPrint('AS checking Done');
            return false;
          }
        } on ShellException catch (_) {
          debugPrint('AS checking Done');
          return false;
        } catch (e) {
          debugPrint('AS checking Done');
          return false;
        }
      } else {
        debugPrint('AS checking Done');
        return false;
      }
    } catch (e) {
      debugPrint('AS checking Done');
      return false;
    }
  }

  Future<bool> checkEmulator() async {
    _pref = await SharedPreferences.getInstance();
    debugPrint('Emulator checking');

    List<ProcessResult> localAppData = await shell.run('echo %localappdata%');
    List<ProcessResult> emulator = await shell
        .cd(localAppData[0].outText.toString())
        .run('dir /b /s /p emulator.exe');
    if (emulator[0]
        .stdout
        .split('\n')[0]
        .toString()
        .trim()
        .contains('\\Sdk\\emulator\\emulator.exe')) {
      if (!_pref.containsKey('emulator_path')) {
        await _pref
            .setString('emulator_path',
                emulator[0].stdout.split('\n')[0].toString().trim())
            .whenComplete(
          () async {
            emulatorPath = _pref.getString('emulator_path');
            try {
              await setPath(emulatorPath!
                  .replaceAll('emulator.exe', '')
                  .replaceAll('"', ''));
              await _pref.setBool('emulator', true);
            } catch (e) {
              debugPrint(e.toString());
            }
          },
        );
      } else {
        emulatorPath = _pref.getString('emulator_path');
        String? emu = await which('emulator');
        if (_pref.getBool('emulator') == false) {
          if (emu == null) {
            try {
              await setPath(emulatorPath!
                  .replaceAll('emulator.exe', '')
                  .replaceAll('"', ''));
              await _pref.setBool('emulator', true);
            } catch (e) {
              debugPrint(e.toString());
            }
          }
        }
      }
      debugPrint('Emulator checking Done');
      return true;
    } else {
      debugPrint('Emulator checking Done');
      return false;
    }
  }
}