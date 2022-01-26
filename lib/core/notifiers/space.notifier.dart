// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:universal_disk_space/universal_disk_space.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';

class SpaceCheck extends ChangeNotifier {
  // The main drive to be used.
  String _drive = 'C';
  String get drive => _drive;

  // Whether or not we are low on storage.
  bool _lowDriveSpace = false;
  bool get lowDriveSpace => _lowDriveSpace;

  // Whether or not there is a conflicting drive error and we cannot choose.
  bool _hasConflictingError = false;
  bool get hasConflictingError => _hasConflictingError;
  List<String> _conflictingDrives = <String>[];
  List<String> get conflictingDrives => _conflictingDrives;

  // List of all drives
  late final int _driveCount = _drives.length;
  int get driveCount => _driveCount;
  final List<String> _drives = <String>[];
  List<String> get drives => _drives;

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
      List<Disk> _disks = _diskSpace.disks;

      // Used to get the value from bytes to GB.
      int _divisibleValue = (1024 * 1024 * 1024);

      Directory _supportDirectory = await getApplicationSupportDirectory();

      for (Disk disk in _disks) {
        // The drive letter.
        String _driveLetter = disk.devicePath.split(':').first;

        _drives.add(_driveLetter);

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
        }
      }

      for (Disk disk in _disks) {
        // If the disk is the main drive, we will use it.
        if (_supportDirectory.path.split(':').first ==
            disk.devicePath.split(':').first) {
          // Checks to see that this main drive is not failing in storage size.
          if (disk.availableSpace / _divisibleValue < warnLessThanGB) {
            _lowDriveSpace = true;
            notifyListeners();
          } else {
            _lowDriveSpace = false;
            notifyListeners();
          }

          _drive = disk.devicePath.split(':').first;
          notifyListeners();

          if (disk.availableSpace / _divisibleValue >= _warnLessThanGB) {
            _lowDriveSpace = false;
            notifyListeners();
            await logger.file(
                LogTypeTag.info, 'Using $_drive drive for data storage.');
            break;
          }
        }
      }

      // If we were not able to find the directory suggested by the path provider
      // as the support directory.
      if (!_drives.contains(_supportDirectory.path.split(':').first)) {
        _hasConflictingError = true;
        _conflictingDrives = _drives;
        notifyListeners();
        await logger.file(LogTypeTag.error,
            'Drive conflicting error found. Drives: ${_drives.join(', ')}');
      } else {
        _hasConflictingError = false;
        _conflictingDrives = <String>[];
        notifyListeners();
        await logger.file(LogTypeTag.info, 'No drive conflicts found');
      }

      // If the directory exists, we will perform a test to see if it is
      // writable.
      if (await _supportDirectory.exists()) {
        // We will write a file to the directory.
        File _testFile = File('${_supportDirectory.path}/fm_test.txt');

        // If the file exists, we will delete it.
        if (await _testFile.exists()) {
          await logger.file(LogTypeTag.warning,
              'Disk test file existing from a previous run.');
          await _testFile.delete();
        }

        // If the file does not exist, we will create it.
        await _testFile.create();

        // Now we expect that this file exists.
        if (!await _testFile.exists()) {
          _hasConflictingError = true;
          _conflictingDrives = _drives;
          notifyListeners();

          await logger.file(LogTypeTag.error,
              'Unable to create file in ${_supportDirectory.path}. This directory is not writable.');
        } else {
          await logger.file(
              LogTypeTag.info, 'Disk space check passed. Disk is writable.');
          await _testFile.delete();
        }
      } else {
        await logger.file(LogTypeTag.warning,
            'The support directory was suggested but not found when checking for space.');
        // If the directory does not exist, we will create it.
        await _supportDirectory.create(recursive: true);
      }

      // Will now check to see if there is a conflicting drive error.
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to check disk space: $_',
          stackTraces: s);
      _hasConflictingError = true;
      _conflictingDrives = _drives;
      notifyListeners();
    }
  }
}
