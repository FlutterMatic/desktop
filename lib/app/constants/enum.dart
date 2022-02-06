enum SetUpTab {
  gettingStarted,
  installFlutter,
  installEditor,
  installGit,
  installJava,
  restart,
}

enum EditorType { vscode, androidStudio, none }

enum Progress {
  none,
  started,
  checking,
  downloading,
  extracting,
  done,
  failed,
  found,
}

enum Java { jdk, jre }

enum PlatformBuildModes { release, profile, debug }
enum WebRenderers { html, canvaskit }
enum AndroidBuildType { appBundle, apk }

enum WorkflowActionStatus {
  /// Workflow has stopped running for some reason.
  stopped,

  /// Workflow is pending to run.
  pending,

  /// Currently running.
  running,

  /// Has been skipped by either the user or auto-detection logic.
  skipped,

  /// There has been a timeout while running.
  timeout,

  /// Failed with a none 0 exit code.
  failed,

  /// Succeeded but with a warning.
  warning,

  /// Successfully completed.
  done,
}
