import 'package:flutter/material.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:unix_disk_space/unix_disk_space.dart';

class SpaceCheck extends ChangeNotifier {
  String _drive = 'C';
  String get drive => _drive;
  bool _lowDriveSpace = false;
  bool get lowDriveSpace => _lowDriveSpace;

  Future<void> checkSpace() async {
    try {
      List<UnixDiskSpaceOutput> disks = await diskSpace();
      for (UnixDiskSpaceOutput disk in disks) {
        await logger.file(
            LogTypeTag.info,
            disk.filesystem!.split('/')[0].replaceAll(':', '').toUpperCase() +
                ' : ' +
                (disk.available! / 1073741824).toStringAsFixed(2) +
                '/' +
                (disk.size! / 1073741824).toStringAsFixed(2) +
                ' GB left');
        if (disk.available! / 1073241824 < 30 &&
            disk.mountpoint!.replaceAll('/', '').toUpperCase() == '') {
          await logger.file(LogTypeTag.warning,
              'Disk ${disk.filesystem!.split('/')[0].replaceAll(':', '').toUpperCase()} has only ${(disk.available! / 1073241824).toStringAsFixed(2)} left.');
          if (disks.length > 1) {
            _lowDriveSpace = true;
            _drive = disks[1].filesystem!.replaceAll(':', '');
            notifyListeners();
          } else {
            _drive = 'C';
            _lowDriveSpace = true;
            notifyListeners();
          }
        } else if (disk.available! / 1073241824 < 30 &&
            disk.mountpoint!.replaceAll('/', '').toUpperCase() == '') {
          _lowDriveSpace = false;
          notifyListeners();
          await logger.file(
              LogTypeTag.info, 'Using $_drive drive for installtion.');
          return;
        }
      }
    } catch (e) {
      await logger.file(LogTypeTag.error, e.toString());
    }
  }
}
