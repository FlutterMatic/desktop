import 'package:flutter/material.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:unix_disk_space/unix_disk_space.dart';

class SpaceCheck extends ChangeNotifier {
  String _drive = 'C';
  String get drive => _drive;
  bool _lowDriveSpace = false;
  bool get lowDriveSpace => _lowDriveSpace;
  
  Future<void> checkSpace() async {
    List<UnixDiskSpaceOutput> disks = await diskSpace();
    for (UnixDiskSpaceOutput disk in disks) {
      // String diskLetter =
      //     disk.mountpoint!.replaceAll('/', '').toUpperCase() == ''
      //         ? 'C'
      //         : disk.mountpoint!.replaceAll('/', '').toUpperCase();

      if (disk.available! / 1073241824 > 30 &&
          disk.mountpoint!.replaceAll('/', '').toUpperCase() == '') {
        await logger.file(LogTypeTag.WARNING,
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
      }
      // print(diskLetter +
      //     ' : ' +
      //     (disk.available! / 1073741824).toStringAsFixed(2) +
      //     '/' +
      //     (disk.size! / 1073741824).toStringAsFixed(2) +
      //     ' GB left');
    }
  }
}
