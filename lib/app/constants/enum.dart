enum WelcomeTab {
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

enum WorkflowActionStatus {
  pending,
  running,
  skipped,
  failed,
  warning,
  done,
}
