import 'dart:io';
import 'package:flutter_installer/utils/constants.dart';
import 'package:process_run/shell.dart';

class Installs {
  Shell shell = Shell();

  Future<void> checkProjects() async {
    projs.clear();
    List<ProcessResult> projectsList =
        await shell.cd(projDir!).run('dir /b /s /p main.dart');
    List temp = await projectsList[0].stdout.split('\n');
    for (int i = 0; i < temp.length; i++) {
      try {
        String value = await temp[i];
        if (!temp[i].toString().contains('\\example\\')) {
          if (!temp[i].toString().contains('\\windows\\')) {
            if (!temp[i].toString().contains('\\macos\\')) {
              if (!temp[i].toString().contains('\\linux\\')) {
                if (temp[i].toString().isNotEmpty) {
                  projs.add(value);
                }
              }
            }
          }
        }
      } catch (e) {
        throw e.toString();
      }
    }
  }
}
