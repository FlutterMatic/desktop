class SpaceState {
  final String drive;
  final bool lowDriveSpace;
  final bool hasConflictingError;
  final int warnLessThanGB;

  const SpaceState({
    this.drive = 'C',
    this.lowDriveSpace = false,
    this.hasConflictingError = false,
    this.warnLessThanGB = 10,
  });

  factory SpaceState.initial() => const SpaceState();

  SpaceState copyWith({
    String? drive,
    bool? lowDriveSpace,
    bool? hasConflictingError,
  }) {
    return SpaceState(
      drive: drive ?? this.drive,
      lowDriveSpace: lowDriveSpace ?? this.lowDriveSpace,
      hasConflictingError: hasConflictingError ?? this.hasConflictingError,
    );
  }
}
