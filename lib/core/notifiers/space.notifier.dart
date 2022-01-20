// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:universal_disk_space/universal_disk_space.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/services.dart';

class SpaceCheck extends ChangeNotifier {
  // The main drive to be used.
  String _drive = 'C';
  String get drive => _drive;

  // Whether or not we are low on storage.
  bool _lowDriveSpace = false;
  bool get lowDriveSpace => _lowDriveSpace;

  // We will warn if less than 15 GB of storage left.
  static const int _warnLessThanGB = 15;
  int get warnLessThanGB => _warnLessThanGB;

  Future<void> checkSpace() async {
    try {
      // Initializes the DiskSpace class.
      DiskSpace _diskSpace = DiskSpace();

      // Scan for disks in the system.
      await _diskSpace.scan();

      // A list of disks in the system.
      List<Disk> disks = _diskSpace.disks;

      // Used to get the value from bytes to GB.
      int _divisibleValue = (1024 * 1024 * 1024);

      for (Disk disk in disks) {
        String _message =
            disk.devicePath.split('/')[0].replaceAll(':', '').toUpperCase() +
                ': ' +
                (disk.availableSpace / _divisibleValue).toStringAsFixed(2) +
                ' GB out of ' +
                ((disk.availableSpace + disk.usedSpace) / _divisibleValue)
                    .toStringAsFixed(2) +
                ' GB left';

        await logger.file(LogTypeTag.info, _message);

        if (disk.availableSpace / _divisibleValue < _warnLessThanGB) {
          // Too low in space for this drive.
          await logger.file(LogTypeTag.warning,
              'Disk ${disk.devicePath.split('/')[0].replaceAll(':', '').toUpperCase()} has only ${(disk.availableSpace / _divisibleValue).toStringAsFixed(2)} left.');

          _lowDriveSpace = true;
          notifyListeners();

          if (disks.length > 1) {
            _drive = disks[1].devicePath.replaceAll(':', '');
            notifyListeners();
          } else {
            _drive = disks.first.devicePath.replaceAll(':', '');

            notifyListeners();
          }
        }

        if (disk.availableSpace / _divisibleValue >= _warnLessThanGB) {
          _lowDriveSpace = false;
          notifyListeners();
          await logger.file(
              LogTypeTag.info, 'Using $_drive drive for data storage.');
          return;
        }
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to check disk space: $_',
          stackTraces: s);
    }
  }
}
