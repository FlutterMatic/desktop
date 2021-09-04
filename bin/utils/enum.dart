/// Application build type.
enum BuildType {
  /// Debug build.
  /// This is the default build type.
  /// It is used for debugging and testing.
  /// It is not optimized for release, performance, size, speed, security.
  debug,

  /// Profile build.
  /// This is used for profiling.
  /// It is not optimized for debugging, testing.
  /// It is not optimized for performance, size, speed, security.
  /// It is similar to release build. Like a preview of release build.
  profile,

  /// Release build.
  /// This is used for release.
  /// It is optimized for release, performance, size, speed, security.
  /// It is similar to profile build. Like a final release build.
  /// It is used for production.
  release,
}

/// Application release type.
enum ReleaseType {
  /// Alpha release.
  /// This release will have many unimplemented features which are not confirmed yet.
  ///
  /// **NOTE**: This release is not ready for production and will be having bugs.
  alpha,

  /// Beta release.
  /// This release may have bugs or features which are not handled completely yet.
  /// **NOTE**: This release is just for previewing the application.
  beta,

  /// Stable release.
  /// This release is ready for production.
  stable,
}
