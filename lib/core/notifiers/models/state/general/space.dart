class SpaceState {
  final String drive;
  final List<String> drives;
  final List<String> conflictingDrives;
  final bool lowDriveSpace;
  final bool hasConflictingError;
  final int warnLessThanGB;

  const SpaceState({
    this.drive = 'C',
    this.lowDriveSpace = false,
    this.hasConflictingError = false,
    this.conflictingDrives = const <String>[],
    this.drives = const <String>[],
    this.warnLessThanGB = 10,
  });

  factory SpaceState.initial() => const SpaceState();

  SpaceState copyWith({
    String? drive,
    List<String>? drives,
    List<String>? conflictingDrives,
    bool? lowDriveSpace,
    bool? hasConflictingError,
  }) {
    return SpaceState(
      drive: drive ?? this.drive,
      drives: drives ?? this.drives,
      conflictingDrives: conflictingDrives ?? this.conflictingDrives,
      lowDriveSpace: lowDriveSpace ?? this.lowDriveSpace,
      hasConflictingError: hasConflictingError ?? this.hasConflictingError,
    );
  }
}
