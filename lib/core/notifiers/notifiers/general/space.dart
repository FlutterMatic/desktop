// 🎯 Dart imports:
import 'dart:collection';
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_disk_space/universal_disk_space.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/notifiers/models/state/general/space.dart';
import 'package:fluttermatic/core/services/logs.dart';

class SpaceNotifier extends StateNotifier<SpaceState> {
  final Reader read;

  SpaceNotifier(this.read) : super(SpaceState.initial());

  final List<String> _drives = [];
  UnmodifiableListView<String> get drives => UnmodifiableListView(_drives);

  final List<String> _conflictingDrives = [];
  UnmodifiableListView<String> get conflictingDrives =>
      UnmodifiableListView(_conflictingDrives);

  /// List of all drives
  late final int _driveCount = _drives.length;
  int get driveCount => _driveCount;

  Future<void> checkSpace() async {
    try {
      // Initializes the DiskSpace class.
      DiskSpace diskSpace = DiskSpace();

      // Scan for disks in the system.
      await diskSpace.scan();

      // A list of disks in the system.
      List<Disk> disks = diskSpace.disks;

      // Used to get the value from bytes to GB.
      int divisibleValue = (1024 * 1024 * 1024);

      Directory supportDirectory = await getApplicationSupportDirectory();

      for (Disk disk in disks) {
        // The drive letter.
        String driveLetter = disk.devicePath.split(':').first;

        _drives.add(driveLetter);

        String message =
            '${disk.devicePath.split('/')[0].replaceAll(':', '').toUpperCase()}: ${(disk.availableSpace / divisibleValue).toStringAsFixed(2)} GB out of ${((disk.availableSpace + disk.usedSpace) / divisibleValue).toStringAsFixed(2)} GB left';

        await logger.file(LogTypeTag.info, message);

        if (disk.availableSpace / divisibleValue < state.warnLessThanGB) {
          // Too low in space for this drive.
          await logger.file(LogTypeTag.warning,
              'Disk ${disk.devicePath.split('/')[0].replaceAll(':', '').toUpperCase()} has only ${(disk.availableSpace / divisibleValue).toStringAsFixed(2)} left.');

          state = state.copyWith(
            lowDriveSpace: true,
          );
        }
      }

      for (Disk disk in disks) {
        // If the disk is the main drive, we will use it.
        if (supportDirectory.path.split(':').first ==
            disk.devicePath.split(':').first) {
          // Checks to see that this main drive is not failing in storage size.
          if (disk.availableSpace / divisibleValue < state.warnLessThanGB) {
            state = state.copyWith(
              lowDriveSpace: true,
            );
          } else {
            state = state.copyWith(
              lowDriveSpace: false,
            );
          }

          state = state.copyWith(
            drive: disk.devicePath.split(':').first,
          );

          if (disk.availableSpace / divisibleValue >= state.warnLessThanGB) {
            state = state.copyWith(
              lowDriveSpace: false,
            );
            await logger.file(LogTypeTag.info,
                'Using ${state.drive} drive for data storage.');
            break;
          }
        }
      }

      // If we were not able to find the directory suggested by the path provider
      // as the support directory.
      if (!_drives.contains(supportDirectory.path.split(':').first)) {
        state.copyWith(
          hasConflictingError: true,
        );

        _conflictingDrives.clear();
        _conflictingDrives.addAll(_drives);

        await logger.file(LogTypeTag.error,
            'Drive conflicting error found. Drives: ${_drives.join(', ')}');
      } else {
        state.copyWith(
          hasConflictingError: false,
        );

        _conflictingDrives.clear();

        await logger.file(LogTypeTag.info, 'No drive conflicts found');
      }

      // If the directory exists, we will perform a test to see if it is
      // writable.
      if (await supportDirectory.exists()) {
        // We will write a file to the directory.
        File testFile = File('${supportDirectory.path}/fm_test.txt');

        // If the file exists, we will delete it.
        if (await testFile.exists()) {
          await logger.file(LogTypeTag.warning,
              'Disk test file existing from a previous run.');
          await testFile.delete();
        }

        // If the file does not exist, we will create it.
        await testFile.create();

        // Now we expect that this file exists.
        if (!await testFile.exists()) {
          state = state.copyWith(
            hasConflictingError: true,
          );

          _conflictingDrives.clear();
          _conflictingDrives.addAll(_drives);

          await logger.file(LogTypeTag.error,
              'Unable to create file in ${supportDirectory.path}. This directory is not writable.');
        } else {
          await logger.file(
              LogTypeTag.info, 'Disk space check passed. Disk is writable.');
          await testFile.delete();
        }
      } else {
        await logger.file(LogTypeTag.warning,
            'The support directory was suggested but not found when checking for space.');
        // If the directory does not exist, we will create it.
        await supportDirectory.create(recursive: true);
      }

      // Will now check to see if there is a conflicting drive error.
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to check disk space: $_',
          stackTraces: s);

      state = state.copyWith(
        hasConflictingError: true,
      );

      _conflictingDrives.clear();
      _conflictingDrives.addAll(_drives);
    }
  }
}
