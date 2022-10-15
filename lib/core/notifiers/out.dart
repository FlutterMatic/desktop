// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/bin/check_services.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/dart.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/flutter.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/projects.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/workflows.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/flutter_sdk.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/fm_api.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/vscode_api.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/adb.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/flutter.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/git.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/java.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/studio.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/vsc.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/connection.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/download.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/search.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/space.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/dart.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/flutter.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/projects.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/workflows.dart';
import 'package:fluttermatic/core/notifiers/notifiers/api/flutter_sdk.dart';
import 'package:fluttermatic/core/notifiers/notifiers/api/fluttermatic.dart';
import 'package:fluttermatic/core/notifiers/notifiers/api/vscode.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/adb.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/flutter.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/git.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/java.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/studio.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/vsc.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/connection.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/download.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/file.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/notifications.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/search.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/space.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/theme.dart';

// API Notifiers
final StateNotifierProvider<FlutterSDKNotifier, FlutterSDKState>
    flutterSdkAPIStateNotifier = StateNotifierProvider(FlutterSDKNotifier.new);

final StateNotifierProvider<FlutterMaticAPINotifier, FlutterMaticAPIState>
    fmAPIStateNotifier = StateNotifierProvider(FlutterMaticAPINotifier.new);

final StateNotifierProvider<VSCodeAPINotifier, VSCodeAPIState>
    vsCodeAPIStateNotifier = StateNotifierProvider(VSCodeAPINotifier.new);

// Checks Notifiers
final StateNotifierProvider<FlutterNotifier, FlutterState>
    flutterNotifierController = StateNotifierProvider(FlutterNotifier.new);

final StateNotifierProvider<JavaNotifier, JavaState> javaNotifierController =
    StateNotifierProvider(JavaNotifier.new);

final StateNotifierProvider<GitNotifier, GitState> gitNotifierController =
    StateNotifierProvider(GitNotifier.new);

final StateNotifierProvider<ADBNotifier, ADBState> adbNotifierController =
    StateNotifierProvider(ADBNotifier.new);

final StateNotifierProvider<AndroidStudioNotifier, AndroidStudioState>
    androidStudioNotifierController =
    StateNotifierProvider(AndroidStudioNotifier.new);

final StateNotifierProvider<VSCodeNotifier, VSCState> vscNotifierController =
    StateNotifierProvider(VSCodeNotifier.new);

// General Notifiers
final StateNotifierProvider<ConnectionNotifier, NetworkState>
    connectionNotifierController =
    StateNotifierProvider(ConnectionNotifier.new);

final StateNotifierProvider<DownloadNotifier, DownloadState>
    downloadStateController = StateNotifierProvider(DownloadNotifier.new);

final StateNotifierProvider<AppSearchNotifier, AppSearchState>
    appSearchStateNotifier = StateNotifierProvider(AppSearchNotifier.new);

final StateNotifierProvider<NotificationsNotifier, void>
    notificationStateController =
    StateNotifierProvider(NotificationsNotifier.new);

final StateNotifierProvider<FileNotifier, void> fileStateNotifier =
    StateNotifierProvider(FileNotifier.new);

final StateNotifierProvider<SpaceNotifier, SpaceState> spaceStateController =
    StateNotifierProvider(SpaceNotifier.new);

final StateNotifierProvider<ThemeNotifier, ThemeState> themeStateController =
    StateNotifierProvider(ThemeNotifier.new);

// Actions Notifiers
final StateNotifierProvider<FlutterActionsNotifier, FlutterActionsState>
    flutterActionsStateNotifier =
    StateNotifierProvider(FlutterActionsNotifier.new);

final StateNotifierProvider<DartActionsNotifier, DartActionsState>
    dartActionsStateNotifier = StateNotifierProvider(DartActionsNotifier.new);

final StateNotifierProvider<ProjectsNotifier, ProjectsState>
    projectsActionStateNotifier = StateNotifierProvider(ProjectsNotifier.new);

final StateNotifierProvider<WorkflowsNotifier, WorkflowsState>
    workflowsActionStateNotifier = StateNotifierProvider(WorkflowsNotifier.new);

final StateNotifierProvider<CheckServicesNotifier, CheckServicesState>
    checkServicesStateNotifier =
    StateNotifierProvider(CheckServicesNotifier.new);
